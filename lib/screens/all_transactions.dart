import 'package:flutter/material.dart';
import 'package:money_move/widgets/lista_de_transacciones.dart';

class AllTransactions extends StatefulWidget {
  const AllTransactions({super.key});

  @override
  State<AllTransactions> createState() => _AllTransactionsState();
}

class _AllTransactionsState extends State<AllTransactions> {
  @override
  Widget build(BuildContext context) {
    return ListaDeTransacciones();
  }
}