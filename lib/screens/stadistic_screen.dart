import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/widgets/charts/balance_trend_chart.dart';
import 'package:money_move/widgets/charts/category_pie_chart.dart';
import 'package:money_move/widgets/charts/chart_slider.dart';
import 'package:money_move/widgets/charts/income_expense_line_chart.dart';
import 'package:money_move/widgets/stats/financial_summary_cards.dart';
import 'package:provider/provider.dart';

class StadisticScreen extends StatelessWidget {
  const StadisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final provider = Provider.of<TransactionProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final saldo = Provider.of<TransactionProvider>(context).saldoActual;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.bar_chart_sharp),
            SizedBox(width: 5),
            Text(strings.stadisticText),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                // Fondo suave basado en tu color primario
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  // Icono opcional para dar contexto
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "\$${saldo.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            FinancialSummaryCards(transactions: provider.transactions),
            SizedBox(height: 20,),
            ChartSlider(
              charts: [
                BalanceTrendChart(transactions: provider.transactions, currentBalance: provider.saldoActual,),
                IncomeExpenseLineChart(transactions: provider.transactions),
              ],
            ),
            SizedBox(height: 20,),
            CategoryPieChart(transactions: provider.transactions),
            SizedBox(height: 20,),
            
          ],
        ),
      ),
    );
  }
}
