import 'package:flutter/material.dart';
// import 'package:money_move/config/app_colors.dart'; // <-- Ya no lo necesitas aquí
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/transaction_provider.dart';

import 'package:money_move/widgets/add_button.dart';
import 'package:money_move/widgets/balance_card.dart';
import 'package:money_move/widgets/ultimas_deudas.dart';
import 'package:money_move/widgets/ultimas_transacciones.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        // Opcional: Si quieres la AppBar transparente como en la otra pantalla
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: Text(
          AppLocalizations.of(context)!.appTitle,
          style: TextStyle(
            color: colorScheme.onSurface, // Texto Negro (Día) / Blanco (Noche)
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
          ],
        ),
      ),
      floatingActionButton: const AddButton(),
    );
  }
}
