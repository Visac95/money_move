import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/widgets/add_transaction_button.dart';
import 'package:money_move/widgets/lista_de_transacciones.dart';

class AllTransactions extends StatelessWidget {
  const AllTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.titleTransactionsScreen, 
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const ListaDeTransacciones(),
      floatingActionButton: const AddTransactionButton(),
    );
  }
}