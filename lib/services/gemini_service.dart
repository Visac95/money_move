import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:money_move/config/app_constants.dart';
import '../config/api_keys.dart';

class GeminiService {
  final GenerativeModel _model;

  // Constructor: inicializa el modelo usando la clave de la API
  GeminiService()
    : _model = GenerativeModel(model: "gemini-2.5-flash", apiKey: geminiApiKey);

  // Función para solicitar la categoría a Gemini
  /// Retorna la categoría sugerida o "manual_category" en caso de error
  Future<String> classifyTransaction(String transactionTitle) async {

    final String categoriesString = AppConstants.categories
        .map((cat) => cat)
        .join(', ');

    String prompt =
        """"Actúa como un clasificador de gastos. Dada la descripción, responde ÚNICAMENTE con una de las siguientes palabras clave, sin explicaciones:
      $categoriesString
      Descripción: '$transactionTitle'.
      """;
    
    try{
      print("🤢🤢 try gemini");
      final content = [Content.text(prompt)];
      print("🤢🤢 $content");
      final response = await _model.generateContent(content);
      print("🤢🤢 $response");


      return response.text?.trim() ?? "manual_category";
    } catch(e) {
      print("🤢🤢 ERROR FATAL DE GEMINI: $e");
      return "manual_category";
      
    }// Resultado de prueba
  }
}
