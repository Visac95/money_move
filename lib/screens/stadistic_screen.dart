import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/widgets/charts/weekly_bar_chart.dart';
import 'package:provider/provider.dart';

class StadisticScreen extends StatelessWidget {
  const StadisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.bar_chart_sharp),
            SizedBox(width: 5),
            Text(strings.stadisticText),
          ],
        ),
      ),
      body: WeeklyBarChart(transactions: provider.transactions),
    );
  }
}
