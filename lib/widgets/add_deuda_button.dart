import 'package:flutter/material.dart';
import 'package:money_move/screens/add_deuda_screen.dart';

class AddDeudaButton extends StatelessWidget {
  const AddDeudaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddDeudaScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      );
  }
}

