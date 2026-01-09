import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui; // 1. IMPORTANTE: Esto nos deja acceder al idioma del sistema

class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'codigo_idioma';

  // Inicializamos en inglés por seguridad, pero 'fetchLocale' lo cambiará rápido
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> fetchLocale() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Buscamos si ya hay algo guardado
    String? languageCode = prefs.getString(_prefKey);

    if (languageCode != null) {
      // CASO A: El usuario ya había elegido un idioma antes. Respetamos eso.
      _locale = Locale(languageCode);
    } else {
      // CASO B: Es la primera vez (o borró datos). Detectamos el sistema.
      
      // Obtenemos el código de idioma del celular (ej: 'es', 'en', 'fr')
      final systemLocale = ui.PlatformDispatcher.instance.locale.languageCode;

      // VALIDACIÓN DE SEGURIDAD:
      // Tu app solo tiene archivos para Español ('es') e Inglés ('en').
      // Si el celular está en Francés o Chino, debemos forzar Inglés para que no explote.
      
      if (systemLocale == 'es') {
        _locale = const Locale('es');
      } else {
        // Para cualquier otro idioma (en, fr, it, etc.), ponemos Inglés por defecto
        _locale = const Locale('en');
      }
    }
    
    // Avisamos a la app que ya decidimos el idioma
    notifyListeners();
  }

  void changeLocale(Locale newLocale) async {
    _locale = newLocale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, newLocale.languageCode);
  }
}