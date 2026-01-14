import 'package:cloud_firestore/cloud_firestore.dart'
    hide Transaction; // <--- 1. Import vital
import 'package:money_move/models/deuda.dart';
import 'package:money_move/models/transaction.dart'; // <--- Asegúrate que este nombre coincida con tu archivo del modelo

class DatabaseService {
  // 2. CORRECCIÓN: Es FirebaseFirestore (no FirebaseForees)
  final CollectionReference _transactionsRef = FirebaseFirestore.instance
      .collection('transactions');

  // --- AGREGAR ---
  Future<void> addTransaction(Transaction transaction) async {
    try {
      // 3. MEJORA: Usamos .set() con tu ID local para que coincidan
      // Así el ID del documento en la nube es igual al ID de tu objeto
      await _transactionsRef.doc(transaction.id).set(transaction.toMap());
    } catch (e) {
      print("Error al guardar: $e ❌");
      rethrow;
    }
  }

  // --- LEER (STREAM) ---
  // Esta función devuelve un "Río de datos" (Stream)
  // Cada vez que cambie algo en la nube, esta lista se actualiza sola.
  Stream<List<Transaction>> getTransactionsStream(String userId) {
    return _transactionsRef
        .where('userId', isEqualTo: userId) // Solo mis gastos
        .orderBy('fecha', descending: true) // Los más nuevos primero
        .snapshots() // <--- Esto abre la conexión en tiempo real
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // Convertimos el dato crudo de Firebase a tu objeto Transaction
            return Transaction.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }

  // --- BORRAR ---
  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsRef.doc(id).delete();
      print("Transacción borrada ✅");
    } catch (e) {
      print("Error al borrar: $e ❌");
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      // .update() solo cambia los campos que le pases, no borra el documento
      await _transactionsRef.doc(transaction.id).update(transaction.toMap());
      print("Transacción actualizada ✅");
    } catch (e) {
      print("Error al actualizar: $e ❌");
      rethrow;
    }
  }

  // ==========================================
  // SECCIÓN DE DEUDAS (CORREGIDA)
  // ==========================================

  final CollectionReference _deudasRef = FirebaseFirestore.instance.collection(
    'deudas',
  );

  // 1. AGREGAR
  Future<void> addDeuda(Deuda deuda) async {
    try {
      await _deudasRef.doc(deuda.id).set(deuda.toMap());
    } catch (e) {
      print("Error al guardar deuda: $e ❌");
      rethrow;
    }
  }

  // 2. LEER (STREAM TIPEADO)
  Stream<List<Deuda>> getDeudasStream(String userId) {
    return _deudasRef
        .where('userId', isEqualTo: userId)
        .snapshots() // Tiempo real
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Deuda.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }

  // 3. ACTUALIZAR
  Future<void> updateDeuda(Deuda deuda) async {
    try {
      await _deudasRef.doc(deuda.id).update(deuda.toMap());
    } catch (e) {
      print("Error al actualizar deuda: $e ❌");
      rethrow;
    }
  }

  // 4. BORRAR
  Future<void> deleteDeuda(String id) async {
    await _deudasRef.doc(id).delete();
  }
}
