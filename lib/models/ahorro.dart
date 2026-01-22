import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Ahorro {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double monto;
  double abono;
  final DateTime fechaInicio;
  final DateTime fechaMeta;
  final String categoria;
  final String emoji; // <--- NUEVO: Para mostrar en la lista
  bool ahorrado; // Esto puede ser "Archivado" o "Completado manualmente"

  Ahorro({
    String? id,
    required this.userId,
    required this.title,
    required this.description,
    required this.monto,
    required this.fechaInicio,
    required this.fechaMeta,
    required this.categoria,
    required this.ahorrado,
    required this.abono,
    this.emoji = '💰', // Emoji por defecto
  }) : id = id ?? uuid.v4();

  // --- GETTERS INTELIGENTES (Para facilitar la UI) ---
  double get porcentaje => (monto == 0) ? 0 : (abono / monto).clamp(0.0, 1.0);
  double get faltaPorAhorrar => (monto - abono) < 0 ? 0 : (monto - abono);
  int get diasParaMeta => fechaMeta.difference(DateTime.now()).inDays;
  // ----------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'monto': monto,
      'abono': abono,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaMeta': fechaMeta.toIso8601String(),
      'categoria': categoria,
      'ahorrado': ahorrado,
      'emoji': emoji,
    };
  }

  factory Ahorro.fromMap(Map<String, dynamic> map) {
    return Ahorro(
      id: map['id'],
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      monto: (map['monto'] ?? 0).toDouble(),
      abono: (map["abono"] ?? 0).toDouble(),
      // Protección contra fechas nulas o mal formadas
      fechaInicio:
          DateTime.tryParse(map['fechaInicio'] ?? '') ?? DateTime.now(),
      fechaMeta:
          DateTime.tryParse(map['fechaMeta'] ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
      categoria: map['categoria'] ?? 'General',
      ahorrado: map["ahorrado"] is int
          ? (map["ahorrado"] == 1)
          : (map["ahorrado"] ?? false),
      emoji: map['emoji'] ?? '💰',
    );
  }

  Ahorro update({
    String? title,
    String? description,
    double? monto,
    double? abono,
    DateTime? fechaInicio,
    DateTime? fechaMeta,
    String? categoria,
    bool? ahorrado,
    String? emoji,
  }) {
    return Ahorro(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      monto: monto ?? this.monto,
      abono: abono ?? this.abono,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaMeta: fechaMeta ?? this.fechaMeta,
      categoria: categoria ?? this.categoria,
      ahorrado: ahorrado ?? this.ahorrado,
      emoji: emoji ?? this.emoji,
    );
  }
}
