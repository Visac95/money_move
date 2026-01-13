import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/providers/locale_provider.dart';
import 'package:provider/provider.dart';

class BalanceTrendChart extends StatelessWidget {
  final List<Transaction> transactions;
  final double currentBalance; // <--- 1. NUEVO PARAMETRO: El saldo real actual

  const BalanceTrendChart({
    super.key,
    required this.transactions,
    required this.currentBalance, 
  });

  @override
  Widget build(BuildContext context) {
    // 2. Usamos la nueva lógica inversa
    final List<FlSpot> spots = _generateBalancePoints();

    // Calcular límites (Misma lógica visual de antes)
    double minY = spots.isEmpty
        ? 0
        : spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.isEmpty
        ? 0
        : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    double margin = (maxY - minY) * 0.1;
    if (margin == 0) margin = 50; 

    final strings = AppLocalizations.of(context)!;

    return AspectRatio(
      aspectRatio: 1.70,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.only(
            right: 18,
            left: 12,
            top: 24,
            bottom: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 20),
                child: Text(
                  strings.saldoEvolutionText,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: LineChart(
                  LineChartData(
                    // Ajustamos el rango Y dinámicamente
                    minY: minY - margin,
                    maxY: maxY + margin,
                    
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => Colors.blueGrey.shade800,
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            return LineTooltipItem(
                              '\$${barSpot.y.toStringAsFixed(2)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < 7) {
                              // Calculamos fecha (0 es hace 6 días, 6 es hoy)
                              final date = DateTime.now().subtract(
                                Duration(days: 6 - index),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat.E(
                                    Provider.of<LocaleProvider>(context, listen: false).locale.toString(),
                                  ).format(date)[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            if (value >= 1000) {
                              return Text(
                                '${(value / 1000).toStringAsFixed(1)}k',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              );
                            }
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: false, 
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 2,
                              strokeColor: Theme.of(context).colorScheme.primary,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              Theme.of(context).colorScheme.primary.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
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

  // --- LÓGICA CORREGIDA ---
  List<FlSpot> _generateBalancePoints() {
    final List<FlSpot> points = [];
    final now = DateTime.now();
    
    // Empezamos con el saldo ACTUAL (el real)
    double runningBalance = currentBalance;

    // Iteramos desde HOY hacia el pasado (0 = Hoy, 1 = Ayer...)
    for (int i = 0; i < 7; i++) {
      final targetDate = now.subtract(Duration(days: i));

      // 1. Guardamos el punto actual.
      // El eje X debe ser ascendente cronológicamente.
      // Si i=0 (hoy), X=6. Si i=6 (hace una semana), X=0.
      points.add(FlSpot((6 - i).toDouble(), runningBalance));

      // 2. Buscamos las transacciones de este día para "deshacerlas"
      // y calcular cuánto dinero teníamos AYER.
      final txsOfDay = transactions.where((tx) =>
          tx.fecha.year == targetDate.year &&
          tx.fecha.month == targetDate.month &&
          tx.fecha.day == targetDate.day
      );

      for (var tx in txsOfDay) {
        if (tx.isExpense) {
          // Si hoy GASTÉ dinero, ayer tenía MÁS dinero.
          runningBalance += tx.monto;
        } else {
          // Si hoy GANÉ dinero, ayer tenía MENOS dinero.
          runningBalance -= tx.monto;
        }
      }
    }

    // Como calculamos de Hoy -> Pasado, la lista está al revés.
    // FlChart necesita que X vaya de menor a mayor.
    // Aunque ya calculamos la X correctamente ((6-i)), el orden en el array importa.
    // points ya tiene los datos correctos, pero FlChart dibuja mejor si están ordenados por X.
    points.sort((a, b) => a.x.compareTo(b.x));

    return points;
  }
}