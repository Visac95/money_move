import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_move/config/app_colors.dart'; // Asegúrate de tener tus colores aquí
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
    maxY = maxY * 1.2; // 20% de margen superior

    final strings = AppLocalizations.of(context)!;

    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Theme.of(context).colorScheme.surfaceContainer,
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
                      color: Theme.of(context).colorScheme.primary,
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
                    maxY: maxY == 0 ? 100 : maxY,

                    // Configuración de interacción (Tooltips)
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) =>
                            Colors.blueGrey.shade800.withValues(alpha: 0.9),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final isIncome = spot.barIndex == 0;
                            return LineTooltipItem(
                              // Mostramos flechita arriba o abajo según sea ingreso o gasto
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

                    gridData: const FlGridData(
                      show: false,
                    ), // Limpio, sin cuadrícula
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ), // Ocultamos montos eje Y para limpieza
                      // Eje X (Días)
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
                                  style: const TextStyle(
                                    color: Colors.grey,
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
                      // LÍNEA 1: INGRESOS (Verde/Azul)
                      LineChartBarData(
                        spots: incomeSpots,
                        isCurved: false,
                        color: AppColors.income,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(
                          show: false,
                        ), // Sin puntos para que sea más fluido
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.income.withValues(
                            alpha: 0.2,
                          ), // Relleno suave
                        ),
                      ),

                      // LÍNEA 2: GASTOS (Rojo)
                      LineChartBarData(
                        spots: expenseSpots,
                        isCurved: false,
                        color: AppColors.expense,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.expense.withValues(
                            alpha: 0.2,
                          ), // Relleno suave
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

// Widget pequeño para la leyenda (Círculo de color + Texto)
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
