import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/widgets/add_transaction_button.dart';
import 'package:money_move/widgets/lista_de_transacciones.dart';

class AllTransactions extends StatefulWidget {
  const AllTransactions({super.key});

  @override
  State<AllTransactions> createState() => _AllTransactionsState();
}

class _AllTransactionsState extends State<AllTransactions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: Center(child: Text("Transacciones"))),
      body: ListaDeTransacciones(),
      floatingActionButton: AddTransactionButton(),
    );
  }
}