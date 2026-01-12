import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // 1. Variable privada en memoria (RAM)
  bool _isDarkMode = true;

  // Getter para que la UI lo lea
  bool get isDarkMode => _isDarkMode;

  // 2. CONSTRUCTOR: Cargamos los datos apenas nace el Provider
  SettingsProvider() {
    _loadFromPrefs();
  }

  // FUNCIÓN 1: Cargar lo guardado (Leer la libreta)
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Leemos la clave 'modoOscuro', si no existe, por defecto es false
    _isDarkMode = prefs.getBool('modoOscuro') ?? true; 
    notifyListeners(); // ¡Avisamos a la app que ya cargamos la preferencia!
  }

  // FUNCIÓN 2: Cambiar y Guardar (Escribir en la libreta)
  Future<void> toggleTheme(bool value) async {
    // A. Actualizamos la RAM (para que la app cambie YA)
    _isDarkMode = value;
    notifyListeners(); 

    // B. Actualizamos el DISCO (para la próxima vez que abras)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modoOscuro', value);
  }
}