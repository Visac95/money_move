import "package:uuid/uuid.dart";

const uuid = Uuid();

class Transaction {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double monto;
  final double saldo;
  final DateTime fecha;
  final String categoria;
  final bool isExpense;
  final String? deudaAsociada;
  final String? ahorroAsociado;

  Transaction({
    String? id,
    required this.userId,
    required this.title,
    required this.description,
    required this.monto,
    required this.saldo,
    required this.fecha,
    required this.categoria,
    required this.isExpense,
    this.deudaAsociada,
    this.ahorroAsociado,
  }) : id = id ?? uuid.v4();

  // 1. TO MAP (Subir) - Esto estaba bien
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'monto': monto,
      'saldo': saldo,
      'fecha': fecha.toIso8601String(),
      'categoria': categoria,
      'isExpense': isExpense,
      'deudaAsociada': deudaAsociada,
      'ahorroAsociado': ahorroAsociado,
    };
  }

  // 2. FROM MAP (Bajar) - AQUÍ ESTÁ LA MEJORA BLINDADA 🛡️
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '', // Protección si viene null
      userId: map['userId'] ?? '',
      title: map['title'] ?? 'Sin título',
      description: map['description'] ?? '',
      
      // Protección numérica robusta
      monto: (map['monto'] is int) 
          ? (map['monto'] as int).toDouble() 
          : (map['monto'] ?? 0.0).toDouble(),
          
      saldo: (map['saldo'] is int) 
          ? (map['saldo'] as int).toDouble() 
          : (map['saldo'] ?? 0.0).toDouble(),

      // --- CORRECCIÓN CRÍTICA DE FECHA ---
      // Usamos tryParse para que no crashee si la fecha está corrupta
      fecha: map['fecha'] != null 
          ? DateTime.tryParse(map['fecha'].toString()) ?? DateTime.now()
          : DateTime.now(),
      // -----------------------------------

      categoria: map['categoria'] ?? 'General',
      
      // Protección Booleana
      isExpense: map['isExpense'] is int 
          ? (map['isExpense'] == 1) 
          : (map['isExpense'] ?? true), // Default a gasto por seguridad
          
      deudaAsociada: map['deudaAsociada'] as String?,
      ahorroAsociado: map['ahorroAsociado'] as String?,
    );
  }
}