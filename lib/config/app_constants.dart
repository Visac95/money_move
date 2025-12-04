import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppConstants {
  static const String appTitle = "MoneyMove App";
  static const String appVersion = "1.0.0";

  static const String localDbName = "money_move_db";

  static const String chooseCategoryManualTitle =
      "Elija la categoría para su transacción";

  static const List<String> categories = [
    "COMIDA",
    "TRANSPORTE",
    "VIVIENDA",
    "OCIO",
    "SALUD",
    "EDUCACION",
    "IGLESIA",
    "EMPLEO",
    "MASCOTA"
        "OTROS",
  ];

  // NUEVO: Mapa de íconos
  static const Map<String, IconData> categoryIcons = {
    'COMIDA': Icons.fastfood,
    'TRANSPORTE': Icons.directions_bus,
    'SALUD': Icons.local_hospital,
    'OCIO': Icons.movie,
    'VIVIENDA': Icons.home,
    'EDUCACION': Icons.school,
    'Servicios': Icons.lightbulb,
    "IGLESIA": Icons.church,
    "EMPLEO": Icons.work,
    'OTROS': Icons.category,
    "MASCOTA": Icons.pets,
  };

  // Función Helper: "Dame el ícono para esta categoría"
  // Si la categoría no existe en el mapa, devolvemos un ícono por defecto
  static IconData getIconForCategory(String category) {
    return categoryIcons[category] ?? Icons.help_outline;
  }
}
