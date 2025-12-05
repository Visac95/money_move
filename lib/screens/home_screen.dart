import 'package:flutter/material.dart';
import 'package:money_move/screens/add_transaction_screen.dart';
import 'package:money_move/widgets/balance_card.dart';
import 'package:money_move/widgets/ultimas_transacciones.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          BalanceCard(),
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
