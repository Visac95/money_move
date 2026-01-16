import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:money_move/models/deuda.dart';
import 'package:money_move/models/transaction.dart';

class DatabaseService {
  final CollectionReference _transactionsRef = FirebaseFirestore.instance
      .collection('transactions');

  // --- AGREGAR ---
  Future<void> addTransaction(Transaction transaction) async {
    try {
      // Usamos .set para asegurar que el ID del documento sea igual al ID interno
      await _transactionsRef.doc(transaction.id).set(transaction.toMap());
      print("✅ Transacción guardada en nube: ${transaction.title}");
    } catch (e) {
      print("❌ Error al guardar: $e");
      rethrow;
    }
  }

  // --- LEER (STREAM BLINDADO) ---
  Stream<List<Transaction>> getTransactionsStream(String userId) {
    return _transactionsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print(
            "🔥 CAMBIO DETECTADO: Recibidos ${snapshot.docs.length} documentos",
          );

          return snapshot.docs.map((doc) {
            // 1. Obtenemos la data cruda
            final data = doc.data() as Map<String, dynamic>;

            // 2. TRUCO DE SEGURIDAD:
            // Sobrescribimos el 'id' con el ID real del documento.
            // Esto evita errores si el campo 'id' interno se borró o está vacío.
            data['id'] = doc.id;

            // 3. Convertimos
            return Transaction.fromMap(data);
          }).toList();
        });
  }

  // --- BORRAR ---
  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsRef.doc(id).delete();
    } catch (e) {
      print("❌ Error al borrar: $e");
    }
  }

  // --- ACTUALIZAR ---
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _transactionsRef.doc(transaction.id).update(transaction.toMap());
    } catch (e) {
      print("❌ Error al actualizar: $e");
      rethrow;
    }
  }

  // ==========================================
  // SECCIÓN DE DEUDAS
  // ==========================================

  final CollectionReference _deudasRef = FirebaseFirestore.instance.collection(
    'deudas',
  );

  Future<void> addDeuda(Deuda deuda) async {
    try {
      await _deudasRef.doc(deuda.id).set(deuda.toMap());
    } catch (e) {
      print("❌ Error al guardar deuda: $e");
      rethrow;
    }
  }

  Stream<List<Deuda>> getDeudasStream(String userId) {
    return _deudasRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Mismo truco de seguridad para deudas
            return Deuda.fromMap(data);
          }).toList();
        });
  }

  Future<void> updateDeuda(Deuda deuda) async {
    try {
      await _deudasRef.doc(deuda.id).update(deuda.toMap());
    } catch (e) {
      print("❌ Error al actualizar deuda: $e");
      rethrow;
    }
  }

  Future<void> deleteDeuda(String id) async {
    await _deudasRef.doc(id).delete();
  }
}
