import 'package:flutter/material.dart';

class AppColors {
  bool isLight = true;

  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color accentColor = Colors.orange;
  // Una versión más oscura para textos o bordes activos
  static const Color primaryDark = Color(0xFF3730A3);

  // Una versión muy suave para fondos de botones secundarios o chips
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color backgroundColor = Color(0xFFEEF2FF);
  // --- COLORES FINANCIEROS (Ya los tienes) ---
  static const Color expenseColor = Color(0xFFEF4444); // Rojo vibrante moderno
  static const Color incomeColor = Color(0xFF10B981); // Verde esmeralda moderno

  // --- NEUTROS ---
  static const Color textDark = Color(
    0xFF1F2937,
  ); // Negro suave (menos duro que el negro puro)
  static const Color textLight = Color(0xFF6B7280); // Gris para subtítulos
  static const Color scaffoldBackground = Color(0xFFF9FAFB); // Blanco humo

  static const Color transactionListIconColor = Color.fromARGB(255, 33, 33, 33);

  static const Color white = Colors.white;
}
