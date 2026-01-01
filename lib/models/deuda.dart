import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Deuda {
  final String id;
  final String title;
  final String description;
  final double monto;
  double abono;
  final String involucrado;
  final DateTime fechaInicio;
  final DateTime fechaLimite;
  final String categoria;
  final bool debo; // true = Gasto, false = Ingreso
  bool pagada;

  Deuda({
    String? id,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'monto': monto,
      "involucrado": involucrado,
      "abono": abono,
      // SQLite no guarda fechas, las guardamos como texto
      "fechaInicio": fechaInicio.toIso8601String(),
      'fechaLimite': fechaLimite.toIso8601String(),
      'categoria': categoria,
      // SQLite no tiene bool, guardamos 1 o 0
      'debo': debo ? 1 : 0,
      "pagada": pagada ? 1 : 0,
    };
  }

  factory Deuda.fromMap(Map<String, dynamic> map) {
    return Deuda(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      monto: map['monto'],
      involucrado: map["involucrado"],
      abono: map["abono"],
      fechaInicio: DateTime.parse(map['fechaInicio']),
      fechaLimite: DateTime.parse(map['fechaLimite']),
      categoria: map['categoria'],
      debo: map['debo'] == 1, // Si es 1 es true, si es 0 es false
      pagada: map["pagada"] == 1,
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
