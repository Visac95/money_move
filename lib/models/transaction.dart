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
}
