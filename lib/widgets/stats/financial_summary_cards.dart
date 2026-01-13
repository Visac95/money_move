import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/screens/ver_transaction_screen.dart';
import 'package:provider/provider.dart'; // Asegúrate de importar tus colores

class FinancialSummaryCards extends StatelessWidget {
  final List<Transaction> transactions;

  const FinancialSummaryCards({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    // 1. CÁLCULOS MATEMÁTICOS
    final stats = _calculateStats();
    final transaction = Provider.of<TransactionProvider>(
      context,
      listen: false,
    ).getTransactionById(stats.maxExpenseId);
    final strings = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          children: [
            // TARJETA 1: TASA DE AHORRO
            Expanded(
              child: _StatCard(
                title: strings.savingRateText,
                value: "${stats.savingsRate.toStringAsFixed(1)}%",
                icon: Icons.savings_outlined,
                color: _getSavingsColor(stats.savingsRate),
                subtitle: stats.savingsRate > 0 ? strings.wellDoneText : strings.beCarefulText,
              ),
            ),
            const SizedBox(width: 12),
            // TARJETA 2: PROMEDIO DIARIO
            Expanded(
              child: _StatCard(
                title: strings.dailyExpenseText,
                value: "\$${stats.dailyAverage.toStringAsFixed(0)}",
                icon: Icons.calendar_today_outlined,
                color: Colors.orange,
                subtitle: strings.promedioEstimadoText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // TARJETA 3: SALDO DEL PERIODO
            Expanded(
              child: _StatCard(
                title: strings.flujoNetoText,
                value: "\$${stats.netBalance.toStringAsFixed(2)}",
                icon: Icons.account_balance_wallet_outlined,
                color: stats.netBalance >= 0
                    ? AppColors.income
                    : AppColors.expense,
                subtitle: strings.ingresosVsGastosText,
              ),
            ),
            const SizedBox(width: 12),
            // TARJETA 4: EL "VAMPIRO" (Gasto más grande)
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VerTransactionScreen(
                      id: transaction!.id,
                      title: transaction.title,
                      description: transaction.description,
                      monto: transaction.monto,
                      fecha: transaction.fecha,
                      categoria: transaction.categoria,
                      isExpense: transaction.isExpense,
                    ),
                  ),
                ),
                child: _StatCard(
                  title: strings.bigerExpensesText,
                  value: "\$${stats.maxExpenseAmount.toStringAsFixed(0)}",
                  icon: Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  subtitle: stats.maxExpenseName, // Ej: "Supermercado"
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- LÓGICA DE NEGOCIO ---
  _StatsResult _calculateStats() {
    if (transactions.isEmpty) {
      return _StatsResult(0, 0, 0, 0, "-", "-");
    }

    double totalIncome = 0;
    double totalExpense = 0;
    double maxExpense = 0;
    String maxExpenseName = "-";
    String maxExpenseId = "-";

    // Encontrar rango de fechas para el promedio diario
    DateTime? firstDate;
    DateTime? lastDate;

    for (var tx in transactions) {
      // Sumatorias
      if (tx.isExpense) {
        totalExpense += tx.monto;
        // Buscar el gasto más grande
        if (tx.monto > maxExpense) {
          maxExpense = tx.monto;
          maxExpenseName = tx.title;
          maxExpenseId = tx.id;
        }
      } else {
        totalIncome += tx.monto;
      }

      // Rango de fechas
      if (firstDate == null || tx.fecha.isBefore(firstDate)) {
        firstDate = tx.fecha;
      }
      if (lastDate == null || tx.fecha.isAfter(lastDate)) lastDate = tx.fecha;
    }

    // 1. Saldo Neto
    final netBalance = totalIncome - totalExpense;

    // 2. Tasa de Ahorro (Cuánto % me quedó)
    double savingsRate = 0;
    if (totalIncome > 0) {
      savingsRate = ((totalIncome - totalExpense) / totalIncome) * 100;
    }

    // 3. Promedio Diario
    // Si solo hay 1 día de diferencia, dividimos por 1. Si son 0 días, es 1.
    int days = 1;
    if (firstDate != null && lastDate != null) {
      days = lastDate.difference(firstDate).inDays + 1;
    }
    final dailyAverage = days > 0 ? totalExpense / days : totalExpense;

    return _StatsResult(
      netBalance,
      savingsRate,
      dailyAverage,
      maxExpense,
      maxExpenseName,
      maxExpenseId,
    );
  }

  Color _getSavingsColor(double rate) {
    if (rate >= 20) return Colors.green; // Excelente
    if (rate > 0) return Colors.blue; // Bien
    return Colors.red; // Mal (Gastas más de lo que ganas)
  }
}

// --- CLASE DE DATOS PRIVADA ---
class _StatsResult {
  final double netBalance;
  final double savingsRate;
  final double dailyAverage;
  final double maxExpenseAmount;
  final String maxExpenseName;
  final String maxExpenseId;

  _StatsResult(
    this.netBalance,
    this.savingsRate,
    this.dailyAverage,
    this.maxExpenseAmount,
    this.maxExpenseName,
    this.maxExpenseId,
  );
}

// --- WIDGET DE TARJETA INDIVIDUAL ---
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        // Sutil borde para dar definición
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
