import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:money_move/models/deuda.dart';
import 'package:money_move/models/transaction.dart';

class DatabaseService {
  final CollectionReference _transactionsRef = FirebaseFirestore.instance
      .collection('transactions');

  final CollectionReference _deudasRef = FirebaseFirestore.instance.collection(
    'deudas',
  );

  // ==========================================
  // 💰 SECCIÓN DE TRANSACCIONES
  // ==========================================

  // --- AGREGAR ---
  Future<void> addTransaction(Transaction transaction) async {
    try {
      // Usamos .set para que el ID del documento coincida con el ID interno (UUID)
      await _transactionsRef.doc(transaction.id).set(transaction.toMap());
    } catch (e) {
      //print("❌ Error al guardar transacción: $e");
      rethrow;
    }
  }

  // --- LEER (CORREGIDO PARA EVITAR CRASH) ---
  Stream<List<Transaction>> getTransactionsStream(String userId) {
    return _transactionsRef
        .where('userId', isEqualTo: userId)
        // Opcional: Para que salgan ordenadas
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // 1. Obtenemos la data
            final data = doc.data() as Map<String, dynamic>;

            // 2. PARCHE DE SEGURIDAD CRÍTICO 🛡️
            // Sobrescribimos el 'id' con el ID real de Firestore.
            // Esto soluciona el error "not-found" al editar.
            data['id'] = doc.id;

            // 3. Convertimos
            return Transaction.fromMap(data);
          }).toList();
        });
  }

  // --- ACTUALIZAR ---
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      // Al usar el ID correcto (gracias al parche de arriba), esto ya no fallará
      await _transactionsRef.doc(transaction.id).update(transaction.toMap());
    } catch (e) {
      //print("❌ Error al actualizar transacción: $e");
      rethrow;
    }
  }

  // --- BORRAR ---
  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsRef.doc(id).delete();
    } catch (e) {
      //print("❌ Error al borrar transacción: $e");
    }
  }

  // ==========================================
  // 💸 SECCIÓN DE DEUDAS
  // ==========================================

  Future<void> addDeuda(Deuda deuda) async {
    try {
      await _deudasRef.doc(deuda.id).set(deuda.toMap());
    } catch (e) {
      //print("❌ Error al guardar deuda: $e");
      rethrow;
    }
  }

  Stream<List<Deuda>> getDeudasStream(String userId) {
    return _deudasRef.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Aplicamos el mismo parche de seguridad a las deudas
        data['id'] = doc.id;
        return Deuda.fromMap(data);
      }).toList();
    });
  }

  Future<void> updateDeuda(Deuda deuda) async {
    try {
      await _deudasRef.doc(deuda.id).update(deuda.toMap());
    } catch (e) {
      //print("❌ Error al actualizar deuda: $e");
      rethrow;
    }
  }

  Future<void> deleteDeuda(String id) async {
    try {
      await _deudasRef.doc(id).delete();
    } catch (e) {
      //print("❌ Error al borrar deuda: $e");
    }
  }
}
