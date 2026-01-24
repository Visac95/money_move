import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_move/models/deuda.dart';
import 'package:money_move/models/invitacion.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/models/user_model.dart';

class DatabaseService {
  final CollectionReference _userRef = FirebaseFirestore.instance.collection(
    'users',
  );
  final CollectionReference _invitacionRef = FirebaseFirestore.instance
      .collection('invitations');
  final CollectionReference _spaceRef = FirebaseFirestore.instance.collection(
    'spaces',
  );

  // ==========================================
  // 🛠️ HELPER PRIVADO (Para no repetir código)
  // ==========================================
  // Esta función decide automáticamente dónde buscar según si le pasas un spaceId o no.
  CollectionReference _getTxCollection(String id, bool? space) {
    if (space ?? false) {
      // 🚀 RUTA SPACE: spaces/{spaceId}/transactions
      return _spaceRef.doc(id).collection("transactions");
    } else {
      // 👤 RUTA PERSONAL: users/{userId}/transactions
      return _userRef.doc(id).collection("transactions");
    }
  }

  // ==========================================
  // 👤 SECCIÓN DE USERS
  // ==========================================

  Future<void> addUser(UserModel userData) async {
    try {
      await _userRef.doc(userData.uid).set(userData.toMap());
    } catch (e) {
      print("💀 Error AddUser: $e");
      rethrow;
    }
  }

  // ==========================================
  // 💰 SECCIÓN DE TRANSACCIONES
  // ==========================================

  // --- AGREGAR ---
  // AHORA RECIBE spaceId para saber dónde guardar
  Future<void> addTransaction(Transaction t, bool? space) async {
    try {
      final ref = _getTxCollection(t.userId, space);
      // Usamos .set para asegurar que el ID sea el que generamos en la app
      await ref.doc(t.id).set(t.toMap());
    } catch (e) {
      print("❌ Error al guardar transacción: $e");
      rethrow;
    }
  }

  // --- LEER (STREAM) ---
  Stream<List<Transaction>> getTransactionsStream(
    String userId,
    String? spaceId,
    bool isSpaceMode, // Usamos esto para decidir qué path tomar
  ) {
    // Si estamos en modo space y hay ID, usamos el ID del space. Si no, null (personal).
    final targetId = (isSpaceMode && spaceId != null) ? spaceId : userId;

    final ref = _getTxCollection(targetId, (isSpaceMode && spaceId != null));

    return ref.snapshots().map(_mapSnapshotToTransactions);
  }

  // --- ACTUALIZAR ---
  Future<void> updateTransaction(Transaction t, bool? space) async {
    try {
      final ref = _getTxCollection(t.userId, space);
      await ref.doc(t.id).update(t.toMap());
    } catch (e) {
      print("❌ Error al actualizar: $e");
      rethrow;
    }
  }

  // --- BORRAR ---
  Future<void> deleteTransaction(String id, bool space) async {
    try {
      final ref = _getTxCollection(id, space);
      await ref.doc(id).delete();
    } catch (e) {
      print("❌ Error al borrar: $e");
    }
  }

  // ==========================================
  // 💸 SECCIÓN DE DEUDAS (Sin cambios mayores)
  // ==========================================

  Future<void> addDeuda(Deuda deuda) async {
    try {
      await _userRef
          .doc(deuda.userId)
          .collection("deudas")
          .doc(deuda.id)
          .set(deuda.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Deuda>> getDeudasStream(String userId) {
    return _userRef.doc(userId).collection("deudas").snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Deuda.fromMap(data);
      }).toList();
    });
  }

  Future<void> updateDeuda(Deuda deuda) async {
    await _userRef
        .doc(deuda.userId)
        .collection("deudas")
        .doc(deuda.id)
        .update(deuda.toMap());
  }

  Future<void> deleteDeuda(String id, String userId) async {
    await _userRef.doc(userId).collection("deudas").doc(id).delete();
  }

  // ==========================================
  // 📩 SECCIÓN DE INVITACIONES
  // ==========================================

  Future<void> addInvitacion(Invitacion i) async {
    try {
      await _invitacionRef.doc(i.codeInvitacion).set(i.toMap());
    } catch (e) {}
  }

  Future<Invitacion?> getActiveInvitationFuture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await _invitacionRef
        .where('creatorId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    return Invitacion.fromMap(data);
  }

  Future<void> deleteInvitacion(String id) async {
    try {
      await _invitacionRef.doc(id).delete();
    } catch (e) {}
  }

  // ✨ HELPER DE MAPEO
  List<Transaction> _mapSnapshotToTransactions(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Transaction.fromMap(data);
    }).toList();
  }
}
