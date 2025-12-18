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

  Transaction({
    String? id,
    required this.title,
    required this.description,
    required this.monto,
    required this.fecha,
    required this.categoria,
    required this.isExpense,
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
    );
  }

  Transaction update({
    String? title,
    String? description,
    double? monto,
    DateTime? fecha,
    String? categoria,
    bool? isExpense,
  }) {
    return Transaction(
      id: id,
      title: this.title,
      description: this.description,
      monto: this.monto,
      fecha: this.fecha,
      categoria: this.categoria,
      isExpense: this.isExpense,
    );
  }
}
