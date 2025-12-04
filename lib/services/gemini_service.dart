import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:money_move/config/app_constants.dart';
import '../config/api_keys.dart';

class GeminiService {
  final GenerativeModel _model;

  // Constructor: inicializa el modelo usando la clave de la API
  GeminiService()
    : _model = GenerativeModel(model: "gemini-2.5-flash", apiKey: geminiApiKey);

  // Función para solicitar la categoría a Gemini
  @override
  Future<String> classifyTransaction(String transactionTitle) async {

    final String categoriesString = AppConstants.categories
        .map((cat) => cat.toUpperCase())
        .join(', ');

    String prompt =
        """"Actúa como un clasificador de gastos. Dada la descripción, responde ÚNICAMENTE con una de las siguientes palabras clave, sin explicaciones:
      $categoriesString
      Descripción: '$transactionTitle'.
      """;
    
    try{
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);


      return response.text?.trim() ?? "manual_category";
    } catch(e) {
      print('Error al conectar con Gemini: $e');
      return "manual_category";
    }// Resultado de prueba
  }
}
