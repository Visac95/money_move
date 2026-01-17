import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/providers/locale_provider.dart';
import 'package:provider/provider.dart';

class IncomeExpenseLineChart extends StatelessWidget {
  final List<Transaction> transactions;

  const IncomeExpenseLineChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // 1. PROCESAMIENTO DE DATOS
    final data = _processData();
    final incomeSpots = data['income']!;
    final expenseSpots = data['expense']!;

    // Calcular el valor máximo para el techo del gráfico (Y Max)
    double maxY = 0;
    for (final spot in incomeSpots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    for (final spot in expenseSpots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    // Si no hay datos, ponemos un techo ficticio para que no se rompa
    if (maxY == 0) maxY = 100;

    // Le damos un poco de aire arriba (20%)
    final double yMaxWithPadding = maxY * 1.2;
    
    // Calculamos un intervalo para que solo salgan 4 o 5 líneas horizontales
    final double interval = yMaxWithPadding / 4;

    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    //final isDark = theme.brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ENCABEZADO Y LEYENDA ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.cashFlowText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  // Leyenda pequeña
                  Row(
                    children: [
                      _LegendIndicator(
                        color: AppColors.income,
                        text: strings.incomesText,
                      ),
                      const SizedBox(width: 10),
                      _LegendIndicator(
                        color: AppColors.expense,
                        text: strings.expencesText,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- EL GRÁFICO ---
              Expanded(
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: yMaxWithPadding,

                    // --- TOOLTIPS (Al tocar) ---
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) =>
                            Colors.blueGrey.shade800.withValues(alpha: 0.9),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final isIncome = spot.barIndex == 0;
                            return LineTooltipItem(
                              '${isIncome ? '⬆' : '⬇'} ${spot.y.toStringAsFixed(0)}',
                              TextStyle(
                                color: isIncome
                                    ? AppColors.income
                                    : const Color(0xFFFF8A80),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                      handleBuiltInTouches: true,
                    ),

                    // --- CUADRÍCULA (Sutil) ---
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false, // Sin líneas verticales (limpieza)
                      horizontalInterval: interval, // Usamos el intervalo calculado
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: theme.dividerColor.withValues(alpha: 0.1), // Muy sutil
                          strokeWidth: 1,
                          dashArray: [5, 5], // Línea punteada para que sea discreto
                        );
                      },
                    ),

                    // --- EJES Y TÍTULOS ---
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      
                      // EJE Y (IZQUIERDA) - Aquí está la magia de los números
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: interval,
                          reservedSize: 40, // Espacio reservado para los números
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox(); // Ocultar el 0 si quieres más limpieza
                            
                            // Formateo compacto (1k, 1.5k, etc)
                            String text;
                            if (value >= 1000) {
                              text = '${(value / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
                            } else {
                              text = value.toInt().toString();
                            }

                            return Text(
                              text,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                fontSize: 10, // Letra pequeñita
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            );
                          },
                        ),
                      ),

                      // EJE X (DÍAS)
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < 7) {
                              final date = DateTime.now().subtract(
                                Duration(days: 6 - index),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat.E(
                                    Provider.of<LocaleProvider>(
                                      context,
                                    ).locale.toString(),
                                  ).format(date)[0].toUpperCase(),
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),

                    // --- LAS DOS LÍNEAS ---
                    lineBarsData: [
                      // LÍNEA 1: INGRESOS
                      LineChartBarData(
                        spots: incomeSpots,
                        isCurved: false, 
                        color: AppColors.income,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.income.withValues(alpha: 0.25),
                              AppColors.income.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),

                      // LÍNEA 2: GASTOS
                      LineChartBarData(
                        spots: expenseSpots,
                        isCurved: false,
                        color: AppColors.expense,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.expense.withValues(alpha: 0.25),
                              AppColors.expense.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LÓGICA DE DATOS ---
  Map<String, List<FlSpot>> _processData() {
    final List<FlSpot> incomeSpots = [];
    final List<FlSpot> expenseSpots = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final dateTarget = now.subtract(Duration(days: i));

      // Filtramos por día
      final txsOfDay = transactions.where(
        (tx) =>
            tx.fecha.year == dateTarget.year &&
            tx.fecha.month == dateTarget.month &&
            tx.fecha.day == dateTarget.day,
      );

      double dailyIncome = 0;
      double dailyExpense = 0;

      for (var tx in txsOfDay) {
        if (!tx.isExpense) {
          dailyIncome += tx.monto;
        } else {
          dailyExpense += tx.monto;
        }
      }

      // X = Índice (0 a 6), Y = Monto
      incomeSpots.add(FlSpot((6 - i).toDouble(), dailyIncome));
      expenseSpots.add(FlSpot((6 - i).toDouble(), dailyExpense));
    }

    return {'income': incomeSpots, 'expense': expenseSpots};
  }
}

// Widget pequeño para la leyenda
class _LegendIndicator extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendIndicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}