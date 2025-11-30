import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_keys.dart';

class GeminiService {
  final GenerativeModel _model;

  // Constructor: inicializa el modelo usando la clave de la API
  GeminiService()
    : _model = GenerativeModel(model: "gemini-2.5-flash", apiKey: geminiApiKey);

  // Función para solicitar la categoría a Gemini
  @override
  Future<String> classifyTransaction(String transactionTitle) async {

    String prompt =
        """"Actúa como un clasificador de gastos. Dada la descripción, responde ÚNICAMENTE con una de las siguientes palabras clave, sin explicaciones:
      COMIDA, TRANSPORTE, VIVIENDA, OCIO, SALUD, EDUCACION, OTROS.
      Descripción: '$transactionTitle'.
      """;
    
    try{
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);


      return response.text?.trim() ?? "OTROS";
    } catch(e) {
      print('Error al conectar con Gemini: $e');
      return "OTROS";
    }

    return "Comida"; // Resultado de prueba
  }
}
