import 'package:flutter/material.dart';
import 'package:money_move/providers/space_provider.dart';
import 'package:money_move/screens/add_transaction_screen.dart';
import 'package:money_move/utils/mode_color_app_bar.dart';
import 'package:provider/provider.dart';

class AddTransactionButton extends StatelessWidget {
  const AddTransactionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SpaceProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      backgroundColor: provider.isInSpace
          ? modeColorAppbar(context, 1)
          : colorScheme.primary,
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
