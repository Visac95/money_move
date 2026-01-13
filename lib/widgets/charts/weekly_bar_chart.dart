import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/models/transaction.dart'; 

class WeeklyBarChart extends StatelessWidget {
  final List<Transaction> transactions;

  const WeeklyBarChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // 1. PREPARACIÓN DE DATOS
    // Calculamos los totales de los últimos 7 días
    final List<_DailyData> weekData = _processLast7Days(transactions);
    
    // Encontramos el valor más alto para escalar el gráfico (Y Max)
    double maxY = 0;
    for (var data in weekData) {
      if (data.income > maxY) maxY = data.income;
      if (data.expense > maxY) maxY = data.expense;
    }
    // Le damos un 20% de aire arriba para que no toque el techo
    maxY = maxY * 1.2; 

    return AspectRatio(
      aspectRatio: 1.5, // Controla qué tan "cuadrado" o "alargado" es
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Theme.of(context).colorScheme.surfaceContainer, // Fondo suave
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Últimos 7 días",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: maxY == 0 ? 100 : maxY, // Evitar división por cero
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.blueGrey,
                        tooltipRoundedRadius: 8,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      // Títulos de la izquierda (montos)
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                      // Títulos de abajo (días)
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < weekData.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  weekData[index].dayLabel,
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
                    ),
                    borderData: FlBorderData(show: false), // Sin bordes feos
                    gridData: const FlGridData(show: false), // Sin cuadrícula (más limpio)
                    barGroups: weekData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          // Barra de Ingresos (Verde/Azul)
                          BarChartRodData(
                            toY: data.income,
                            color: AppColors.income,
                            width: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          // Barra de Gastos (Roja)
                          BarChartRodData(
                            toY: data.expense,
                            color: AppColors.expense,
                            width: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                        barsSpace: 4, // Espacio entre ingreso y gasto
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LÓGICA DE AGRUPACIÓN (Privada) ---
  List<_DailyData> _processLast7Days(List<Transaction> txs) {
    final List<_DailyData> last7Days = [];
    final now = DateTime.now();

    // Iteramos 7 veces hacia atrás (hoy, ayer, anteayer...)
    for (int i = 6; i >= 0; i--) {
      final dateTarget = now.subtract(Duration(days: i));
      
      // Filtramos las transacciones de ESE día específico
      final txsOfDay = txs.where((tx) {
        return tx.fecha.year == dateTarget.year &&
               tx.fecha.month == dateTarget.month &&
               tx.fecha.day == dateTarget.day;
      });

      double dailyIncome = 0;
      double dailyExpense = 0;

      for (var tx in txsOfDay) {
        if (!tx.isExpense) {
          dailyIncome += tx.monto;
        } else {
          dailyExpense += tx.monto;
        }
      }

      // Creamos la etiqueta del día (Ej: "Lun", "Mar")
      final dayName = DateFormat.E('es').format(dateTarget); // Requiere inicializar intl

      last7Days.add(_DailyData(dayName, dailyIncome, dailyExpense));
    }
    return last7Days;
  }
}

// Clase helper pequeñita para organizar los datos
class _DailyData {
  final String dayLabel;
  final double income;
  final double expense;
  _DailyData(this.dayLabel, this.income, this.expense);
}