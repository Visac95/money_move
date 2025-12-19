import 'package:flutter/material.dart';
import 'package:money_move/widgets/add_transaction_button.dart';
import 'package:money_move/widgets/balance_card.dart';
import 'package:money_move/widgets/ultimas_deudas.dart';
import 'package:money_move/widgets/ultimas_transacciones.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(title: Text("MoneyMove")),
      body: Column(
        children: [
          BalanceCard(),
          UltimasTransacciones(),
          UltimasDeudas(),
        ],
      ),
    );
  }
}
