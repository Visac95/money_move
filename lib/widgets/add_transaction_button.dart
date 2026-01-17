import 'package:flutter/material.dart';
import 'package:money_move/screens/add_transaction_screen.dart';

class AddTransactionButton extends StatelessWidget {
  const AddTransactionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "btn_guardar_transaccion",
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
        );
      },
      child: Icon(Icons.add),
    );
  }
}
