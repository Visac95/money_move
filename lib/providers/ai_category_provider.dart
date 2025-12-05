// En lib/providers/ai_category_provider.dart

import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class AiCategoryProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService(); // Instancia del servicio
  String? _manualCategory;
  String? get manualCategory => _manualCategory;
  set manualCategory(String? value) {
    _manualCategory = value;
    notifyListeners(); // Notificamos el cambio
  }
  // Estado de carga (para mostrar un Spinner)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Resultado de la última clasificación
  String _suggestedCategory = 'manual_category'; 
  String get suggestedCategory => _suggestedCategory;

  // --- FUNCIÓN PRINCIPAL ---
  Future<void> requestClassification(String title) async {
    if (_manualCategory != null) return;
    if (title.trim().isEmpty) {
      _suggestedCategory = 'manual_category';
      return;
    }
    
    _isLoading = true;
    notifyListeners(); // Avisamos a la UI que el spinner debe aparecer

    try {
      // Llamamos al servicio (y esperamos el resultado)
      final result = await _geminiService.classifyTransaction(title);
      
      _suggestedCategory = result;

    } catch (e) {
      _suggestedCategory = 'manual_category'; 

    } finally {
      _isLoading = false;
      notifyListeners(); // Avisamos a la UI que el spinner debe desaparecer
    }
  }

  void resetCategory () {
    _suggestedCategory = "";
    _manualCategory = null;
    notifyListeners();
  }
}