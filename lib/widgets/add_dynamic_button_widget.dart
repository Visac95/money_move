import 'package:flutter/material.dart';
import 'package:money_move/providers/space_provider.dart';
import 'package:money_move/utils/mode_color_app_bar.dart';
import 'package:provider/provider.dart';

class AddDynamicButtonWidget extends StatelessWidget {
  final dynamic screen;
  const AddDynamicButtonWidget({super.key, required this.screen});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SpaceProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    return FloatingActionButton(
      heroTag: "addDynamicButton",
      backgroundColor: provider.isInSpace
          ? modeColorAppbar(context, 1)
          : colorScheme.primary,
      onPressed: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => screen));
      },
      child: Icon(Icons.add),
    );
  }
}
