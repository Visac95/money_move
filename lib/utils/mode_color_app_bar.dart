import 'package:flutter/material.dart';
import 'package:money_move/models/user_model.dart';
import 'package:money_move/providers/space_provider.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:provider/provider.dart';

Color modeColorAppbar(BuildContext context, double? alpha) {
  UserModel? user = Provider.of<UserProvider>(context).usuarioActual;
  ColorScheme colorScheme = Theme.of(context).colorScheme;
  bool isSpaceMode = Provider.of<SpaceProvider>(context).isSpaceMode;
  String? spaceId = user?.spaceId;

  if (spaceId != null) {
    if (isSpaceMode) {
      return colorScheme.inversePrimary.withValues(alpha: alpha ?? 0.4);
    } else {
      return colorScheme.primary.withValues(alpha: alpha ?? 0.4);
    }
  } else {
    return Colors.transparent;
  }
}
