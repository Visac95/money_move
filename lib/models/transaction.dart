import "package:uuid/uuid.dart";

const uuid = Uuid();

class Transaction {
  final String id;
  final String userId; // <--- 1. NUEVO: Vital para seguridad en la nube
  final String title;
  final String description;
  final double monto;
  final double saldo;
  final DateTime fecha;
  final String categoria;
  final bool isExpense;
  final String? deudaAsociada;

  Transaction({
    String? id,
    required this.userId, // <--- Requerido ahora
    required this.title,
    required this.description,
    required this.monto,
    required this.saldo,
    required this.fecha,
    required this.categoria,
    required this.isExpense,
    this.deudaAsociada,
  }) : id = id ?? uuid.v4(); // Mantenemos tu lógica de UUID, ¡es excelente!

  // 1. TO MAP (Para subir a Firebase)
  Map<String, dynamic> toMap() {
    return {
      // 'id': id,  <-- OJO: En Firestore, el ID suele ir como nombre del documento, no dentro. 
      // Pero si quieres guardarlo dentro también por seguridad, déjalo.
      'id': id, 
      'userId': userId, // <--- Guardamos a quién pertenece
      'title': title,
      'description': description,
      'monto': monto,
      'saldo': saldo,
      'fecha': fecha.toIso8601String(),
      'categoria': categoria,
      
      // CAMBIO RECOMENDADO: Firestore acepta booleanos nativos.
      // Ya no necesitas convertir a 1 o 0.
      'isExpense': isExpense, 
      
      'deudaAsociada': deudaAsociada,
    };
  }

  // 2. FROM MAP (Para bajar de Firebase)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'], // Ojo aquí (ver nota abajo)
      userId: map['userId'] ?? '', // Prevención de nulos
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      monto: (map['monto'] ?? 0).toDouble(), // Firebase a veces devuelve int, forzamos double
      saldo: (map['saldo'] ?? 0).toDouble(),
      fecha: DateTime.parse(map['fecha']),
      categoria: map['categoria'] ?? 'General',
      
      // ADAPTACIÓN HÍBRIDA:
      // Esto hace que tu app lea bien SI ES un booleano (Firebase)
      // O SI ES un entero (tu base de datos vieja SQLite si la tienes)
      isExpense: map['isExpense'] is int 
          ? (map['isExpense'] == 1) 
          : map['isExpense'], 
          
      deudaAsociada: map['deudaAsociada'] as String?,
    );
  }
}