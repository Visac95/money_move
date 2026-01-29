import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/screens/loading_screen.dart';
import 'package:money_move/utils/mode_color_app_bar.dart';
import 'package:money_move/widgets/add_button.dart';
import 'package:money_move/widgets/balance_card.dart';
import 'package:money_move/widgets/charts/category_pie_chart.dart';
import 'package:money_move/widgets/drawer_user.dart';
import 'package:money_move/widgets/settings_button.dart';
import 'package:money_move/widgets/ultimas_deudas.dart';
import 'package:money_move/widgets/ultimas_transacciones.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tProvider = Provider.of<TransactionProvider>(context);

    if (tProvider.isLoading) {
      return const LoadingScreen();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: modeColorAppbar(context, 0.4),
        elevation: 0,

        title: Text(
          AppLocalizations.of(context)!.appTitle,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [settingsButton(context)],
        leading: LeadingDrawer(),
      ),

      drawer: drawerUser(context),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            BalanceCard(
              totalAmount: tProvider.saldoActual,
              expenseAmount: tProvider.totalEgresos,
              incomeAmount: tProvider.totalIngresos,
              withFilterButton: false,
            ),
            UltimasTransacciones(),
            UltimasDeudas(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CategoryPieChart(transactions: tProvider.transactions),
            ),
          ],
        ),
      ),
      floatingActionButton: const AddButton(),
    );
  }
}
