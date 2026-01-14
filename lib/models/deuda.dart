import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Deuda {
  final String id;
  final String userId; // <--- 1. NUEVO: Seguridad (Dueño de la deuda)
  final String title;
  final String description;
  final double monto;
  double abono;
  final String involucrado;
  final DateTime fechaInicio;
  final DateTime fechaLimite;
  final String categoria;
  final bool debo; 
  bool pagada;

  Deuda({
    String? id,
    required this.userId, // <--- Requerido
    required this.title,
    required this.description,
    required this.monto,
    required this.involucrado,
    required this.fechaInicio,
    required this.fechaLimite,
    required this.categoria,
    required this.debo,
    required this.pagada,
    required this.abono,
  }) : id = id ?? uuid.v4();

  // TO MAP (Subir a la nube)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId, // <--- Guardamos dueño
      'title': title,
      'description': description,
      'monto': monto,
      'involucrado': involucrado,
      'abono': abono,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaLimite': fechaLimite.toIso8601String(),
      'categoria': categoria,
      'debo': debo,     // Firebase acepta booleanos directos
      'pagada': pagada, 
    };
  }

  // FROM MAP (Bajar de la nube)
  factory Deuda.fromMap(Map<String, dynamic> map) {
    return Deuda(
      id: map['id'],
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      // Protección: Si Firebase devuelve int, lo forzamos a double
      monto: (map['monto'] ?? 0).toDouble(), 
      involucrado: map["involucrado"] ?? '',
      abono: (map["abono"] ?? 0).toDouble(),
      fechaInicio: DateTime.parse(map['fechaInicio']),
      fechaLimite: DateTime.parse(map['fechaLimite']),
      categoria: map['categoria'] ?? 'General',
      
      // Híbrido: Lee bien si es 1/0 (viejo) o true/false (nuevo)
      debo: map['debo'] is int ? (map['debo'] == 1) : map['debo'],
      pagada: map["pagada"] is int ? (map["pagada"] == 1) : map["pagada"],
    );
  }

  Deuda update({
    String? title,
    String? description,
    double? monto,
    String? involucrado,
    double? abono,
    DateTime? fechaInicio,
    DateTime? fechaLimite,
    String? categoria,
    bool? debo,
    bool? pagada,
  }) {
    return Deuda(
      id: id,
      userId: userId, // Mantenemos el mismo userId
      title: title ?? this.title,
      description: description ?? this.description,
      monto: monto ?? this.monto,
      involucrado: involucrado ?? this.involucrado,
      abono: abono ?? this.abono,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      categoria: categoria ?? this.categoria,
      debo: debo ?? this.debo,
      pagada: pagada ?? this.pagada,
    );
  }
}