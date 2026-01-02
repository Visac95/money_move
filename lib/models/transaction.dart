import "package:uuid/uuid.dart";

const uuid = Uuid();

class Transaction {
  final String id;
  final String title;
  final String description;
  final double monto;
  final DateTime fecha;
  final String categoria;
  final bool isExpense; // true = Gasto, false = Ingreso
  final String? deudaAsociada;

  Transaction({
    String? id,
    required this.title,
    required this.description,
    required this.monto,
    required this.fecha,
    required this.categoria,
    required this.isExpense,
    this.deudaAsociada
  }) : id = id ?? uuid.v4();

  // 1. Convertir: De Objeto a Mapa (Para GUARDAR en la DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'monto': monto,
      // SQLite no guarda fechas, las guardamos como texto
      'fecha': fecha.toIso8601String(),
      'categoria': categoria,
      // SQLite no tiene bool, guardamos 1 o 0
      'isExpense': isExpense ? 1 : 0,
      'deudaAsociada': deudaAsociada,
    };
  }

  // 2. Convertir: De Mapa a Objeto (Para LEER de la DB)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      monto: map['monto'],
      fecha: DateTime.parse(map['fecha']),
      categoria: map['categoria'],
      isExpense: map['isExpense'] == 1, // Si es 1 es true, si es 0 es false
      deudaAsociada: map['deudaAsociada'],
    );
  }

  Transaction update({
    String? title,
    String? description,
    double? monto,
    DateTime? fecha,
    String? categoria,
    bool? isExpense,
    String? deudaAsociada
  }) {
    return Transaction(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      categoria: categoria ?? this.categoria,
      isExpense: isExpense ?? this.isExpense,
      deudaAsociada: deudaAsociada ?? this.deudaAsociada,
    );
  }
}
