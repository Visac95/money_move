import 'package:flutter/material.dart';
import 'package:money_move/models/user_model.dart';
import 'package:money_move/providers/space_provider.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:provider/provider.dart';

Color modeColorAppbar(
  BuildContext context,
  double? alpha, {
  bool? isTranxScreen,
}) {
  UserModel? user = Provider.of<UserProvider>(context).usuarioActual;
  ColorScheme colorScheme = Theme.of(context).colorScheme;
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  bool isSpaceMode = Provider.of<SpaceProvider>(context).isSpaceMode;
  String? spaceId = user?.spaceId;

  if (spaceId != null) {
    if (isTranxScreen != null && isTranxScreen) {
      if (isSpaceMode) {
        return isDark ? Color(0xFF623B0D) : Color(0xFFECCC95);
      } else {
        return isDark ? Color(0xFF3F436E) : Color(0xFFB2AFEF);
      }
    }
    if (isSpaceMode) {
      return colorScheme.inversePrimary.withValues(alpha: alpha ?? 0.4);
    } else {
      return colorScheme.primary.withValues(alpha: alpha ?? 0.4);
    }
  }
  if (isTranxScreen != null && isTranxScreen) {
    return isDark ? Color(0xFF121212) : Color(0xFFF9FAFB);
  } else {
    return Colors.transparent;
  }
}
