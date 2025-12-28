import 'package:flutter/material.dart';

class AppConstants {

  // 1. Estas son las LLAVES INTERNAS. 
  // Esto es lo que se guarda en la Base de Datos (Firebase/SQLite).
  static const String catFood = 'cat_food';
  static const String catTransport = 'cat_transport';
  static const String catLeisure = 'cat_leisure';
  static const String catHealth = 'cat_health';
  static const String catEducation = 'cat_education';
  static const String catChurch = 'cat_church';
  static const String catJob = 'cat_job';
  static const String catPet = 'cat_pet';
  static const String catHome = 'cat_home';
  static const String catServices = 'cat_services';
  static const String catDebt = 'cat_debt';
  static const String catOthers = 'cat_others';

  // Lista de claves para iterar
  static const List<String> categories = [
    catFood,
    catTransport,
    catLeisure,
    catHealth,
    catEducation,
    catChurch,
    catJob,
    catPet,
    catHome,
    catServices,
    catDebt,
    catOthers,
  ];

  // Mapa de íconos usando las CLAVES
  static const Map<String, IconData> categoryIcons = {
    catFood: Icons.fastfood,
    catTransport: Icons.directions_bus,
    catHealth: Icons.local_hospital,
    catLeisure: Icons.movie,
    catHome: Icons.house,
    catEducation: Icons.school,
    catServices: Icons.lightbulb,
    catChurch: Icons.church,
    catJob: Icons.work,
    catOthers: Icons.category,
    catPet: Icons.pets,
    catDebt : Icons.receipt_long,
  };

  static IconData getIconForCategory(String categoryKey) {
    return categoryIcons[categoryKey] ?? Icons.help_outline;
  }
}