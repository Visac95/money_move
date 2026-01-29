import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/utils/mode_color_app_bar.dart';
import 'package:money_move/widgets/charts/balance_trend_chart.dart';
import 'package:money_move/widgets/charts/category_pie_chart.dart';
import 'package:money_move/widgets/charts/chart_slider.dart';
import 'package:money_move/widgets/charts/income_expense_line_chart.dart';
import 'package:money_move/widgets/mode_toggle.dart';
import 'package:money_move/widgets/settings_button.dart';
import 'package:money_move/widgets/small_box_saldo.dart';
import 'package:money_move/widgets/stats/financial_summary_cards.dart';
import 'package:provider/provider.dart';

class StadisticScreen extends StatelessWidget {
  const StadisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final provider = Provider.of<TransactionProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.bar_chart_sharp),
            SizedBox(width: 5),
            Text(strings.stadisticText),
          ],
        ),
        backgroundColor: modeColorAppbar(context, 0.4),
        actions: [
          smallBoxSaldo(context, colorScheme),
          SizedBox(width: 5,),
          ModeToggle(bigWidget: false),
          settingsButton(context),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            FinancialSummaryCards(transactions: provider.transactions),
            SizedBox(height: 20),
            ChartSlider(
              charts: [
                BalanceTrendChart(
                  transactions: provider.transactions,
                  currentBalance: provider.saldoActual,
                ),
                IncomeExpenseLineChart(transactions: provider.transactions),
              ],
            ),
            SizedBox(height: 20),
            CategoryPieChart(transactions: provider.transactions),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
