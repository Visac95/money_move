import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/utils/category_translater.dart';

// Enum para manejar los filtros de forma limpia
enum TimeRange { hoy, semana, mes, anio, todo }

class CategoryPieChart extends StatefulWidget {
  final List<Transaction> transactions;

  const CategoryPieChart({super.key, required this.transactions});

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  // Estado local para el filtro seleccionado
  TimeRange _selectedRange = TimeRange.mes;
  // Estado para saber qué sección se está tocando (para animación)
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // 1. FILTRADO DE DATOS
    final filteredTransactions = _filterByTime(
      widget.transactions,
      _selectedRange,
    );

    // 2. AGRUPACIÓN POR CATEGORÍA
    final categoryData = _groupExpensesByCategory(filteredTransactions);

    final strings = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- HEADER CON FILTRO ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.categoryExpencesText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                // Dropdown pequeño y elegante para el filtro
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TimeRange>(
                      value: _selectedRange,
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: TimeRange.hoy,
                          // Asegúrate de tener 'todayText' en tu AppLocalizations,
                          // si no, usa Text("Hoy") temporalmente.
                          child: Text(strings.hoyText),
                        ),
                        DropdownMenuItem(
                          value: TimeRange.semana,
                          child: Text(strings.thisWeekText),
                        ),
                        DropdownMenuItem(
                          value: TimeRange.mes,
                          child: Text(strings.thisMonthText),
                        ),
                        DropdownMenuItem(
                          value: TimeRange.anio,
                          child: Text(strings.thisYearText),
                        ),
                        DropdownMenuItem(
                          value: TimeRange.todo,
                          child: Text(strings.todoText),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedRange = value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- CUERPO DEL GRÁFICO ---
            categoryData.isEmpty
                ? _buildEmptyState()
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PARTE 1: EL GRÁFICO CIRCULAR
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 200, // Altura del pastel
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback:
                                    (FlTouchEvent event, pieTouchResponse) {
                                      setState(() {
                                        if (!event
                                                .isInterestedForInteractions ||
                                            pieTouchResponse == null ||
                                            pieTouchResponse.touchedSection ==
                                                null) {
                                          _touchedIndex = -1;
                                          return;
                                        }
                                        _touchedIndex = pieTouchResponse
                                            .touchedSection!
                                            .touchedSectionIndex;
                                      });
                                    },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace:
                                  2, // Espacio blanco entre rebanadas
                              centerSpaceRadius: 40, // Radio del hueco (Donut)
                              sections: _generateSections(categoryData),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // PARTE 2: LA LEYENDA (Lista de categorías)
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: categoryData.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _LegendItem(
                                color: _getColorForCategory(entry.key),
                                text: getCategoryName(context, entry.key),
                                percent:
                                    "${(entry.value.percent).toStringAsFixed(1)}%",
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET DE ESTADO VACÍO ---
  Widget _buildEmptyState() {
    final strings = AppLocalizations.of(context)!;
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              strings.noExpensesThisPeriodText,
              style: TextStyle(color: Colors.grey.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }

  // --- LÓGICA DE FILTRADO ---
  List<Transaction> _filterByTime(List<Transaction> txs, TimeRange range) {
    final now = DateTime.now();
    // Filtramos solo gastos (isExpense: true) porque mezclar ingresos rompe el gráfico
    final expenses = txs.where((tx) => tx.isExpense).toList();

    return expenses.where((tx) {
      switch (range) {
        case TimeRange.hoy:
          return tx.fecha.year == now.year &&
              tx.fecha.month == now.month &&
              tx.fecha.day == now.day;
        case TimeRange.semana:
          // Últimos 7 días
          return tx.fecha.isAfter(now.subtract(const Duration(days: 7)));
        case TimeRange.mes:
          return tx.fecha.month == now.month && tx.fecha.year == now.year;
        case TimeRange.anio:
          return tx.fecha.year == now.year;
        case TimeRange.todo:
          return true;
      }
    }).toList();
  }

  // --- LÓGICA DE AGRUPACIÓN Y CÁLCULO ---
  Map<String, ({double amount, double percent})> _groupExpensesByCategory(
    List<Transaction> txs,
  ) {
    if (txs.isEmpty) return {};

    final Map<String, double> totals = {};
    double totalGlobal = 0;

    // Sumar montos por categoría
    for (var tx in txs) {
      totals[tx.categoria] = (totals[tx.categoria] ?? 0) + tx.monto;
      totalGlobal += tx.monto;
    }

    // Calcular porcentajes
    final Map<String, ({double amount, double percent})> result = {};
    totals.forEach((key, value) {
      result[key] = (amount: value, percent: (value / totalGlobal) * 100);
    });

    // Ordenar de mayor a menor porcentaje
    final sortedKeys = result.keys.toList(growable: false)
      ..sort((k1, k2) => result[k2]!.amount.compareTo(result[k1]!.amount));

    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, result[key]!)),
    );
  }

  // --- GENERACIÓN DE SECCIONES DEL GRÁFICO ---
  List<PieChartSectionData> _generateSections(
    Map<String, ({double amount, double percent})> data,
  ) {
    return List.generate(data.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 18.0 : 12.0; // El texto crece si se toca
      final radius = isTouched ? 60.0 : 50.0; // La rebanada crece si se toca

      final key = data.keys.elementAt(i);
      final value = data[key]!;

      return PieChartSectionData(
        color: _getColorForCategory(key),
        value: value.amount,
        title:
            '${value.percent.round()}%', // Solo mostramos el % dentro del pastel
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
        ),
      );
    });
  }

  // --- COLORES CONSISTENTES ---
  Color _getColorForCategory(String category) {
    // Generamos un color basado en el nombre de la categoría para que siempre sea el mismo
    // Puedes reemplazar esto con un Map manual si quieres colores específicos para "Comida", etc.
    final int hash = category.codeUnits.reduce((a, b) => a + b);
    return Colors.primaries[hash % Colors.primaries.length];
  }
}

// --- WIDGET PEQUEÑO PARA LA LEYENDA ---
class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  final String percent;

  const _LegendItem({
    required this.color,
    required this.text,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          percent,
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
