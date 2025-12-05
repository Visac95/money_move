import 'package:flutter/material.dart';
import 'package:money_move/screens/add_transaction_screen.dart';
import 'package:money_move/widgets/balance_card.dart';
import 'package:money_move/widgets/lista_de_transacciones.dart';
import 'package:money_move/widgets/ultimas_transacciones.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BalanceCard(),
          //ListaDeTransacciones(),
          UltimasTransacciones(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
