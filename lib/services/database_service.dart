import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_move/models/ahorro.dart';
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
  CollectionReference _getCollection(String id, bool? space, String colletion) {
    if (space ?? false) {
      // 🚀 RUTA SPACE: spaces/{spaceId}/transactions
      return _spaceRef.doc(id).collection(colletion);
    } else {
      // 👤 RUTA PERSONAL: users/{userId}/transactions
      return _userRef.doc(id).collection(colletion);
    }
  }

  // ==========================================
  // 👤 SECCIÓN DE USERS
  // ==========================================

  Future<void> addUser(UserModel userData) async {
    try {
      await _userRef.doc(userData.uid).set(userData.toMap());
    } catch (e) {
      ////print("💀 Error AddUser: $e");
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
      final ref = _getCollection(t.userId, space, "transactions");
      // Usamos .set para asegurar que el ID sea el que generamos en la app
      await ref.doc(t.id).set(t.toMap());
    } catch (e) {
      ////print("❌ Error al guardar transacción: $e");
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

    final ref = _getCollection(
      targetId,
      (isSpaceMode && spaceId != null),
      "transactions",
    );

    return ref.snapshots().map(_mapSnapshotToTransactions);
  }

  // --- ACTUALIZAR ---
  Future<void> updateTransaction(Transaction t, bool? space) async {
    try {
      final ref = _getCollection(t.userId, space, "transactions");
      await ref.doc(t.id).update(t.toMap());
    } catch (e) {
      ////print("❌ Error al actualizar: $e");
      rethrow;
    }
  }

  // --- BORRAR ---
  Future<void> deleteTransaction(Transaction t, bool space) async {
    try {
      ////print("🤐🫤☹️inicio borrado");
      final ref = _getCollection(t.userId, space, "transactions");
      await ref.doc(t.id).delete();
      ////print("🗑️ Transacción borrada en DB: ${t.id}");
    } catch (e) {
      ////print("❌❌❌❌ Error al borrar: $e");
    }
  }

  // ==========================================
  // 💸 SECCIÓN DE DEUDAS (Sin cambios mayores)
  // ==========================================

  Future<void> addDeuda(Deuda d, bool space) async {
    ////print("😶‍🌫️😶‍🌫️😶‍🌫️ 6");
    try {
      final ref = _getCollection(d.userId, space, "deudas");
      // Usamos .set para asegurar que el ID sea el que generamos en la app
      await ref.doc(d.id).set(d.toMap());
    } catch (e) {
      ////print("❌ Error al guardar deuda: $e");
      rethrow;
    }
    ////print("😶‍🌫️😶‍🌫️😶‍🌫️ 8 ID: ${d.userId}");
  }

  Stream<List<Deuda>> getDeudasStream(
    String userId,
    String? spaceId,
    bool isSpaceMode,
  ) {
    // Si estamos en modo space y hay ID, usamos el ID del space. Si no, null (personal).
    final targetId = (isSpaceMode && spaceId != null) ? spaceId : userId;

    final ref = _getCollection(
      targetId,
      (isSpaceMode && spaceId != null),
      "deudas",
    );
    return ref.snapshots().map(_mapSnapshotToDeudas);
  }

  Future<void> updateDeuda(Deuda deuda, bool space) async {
    final ref = _getCollection(deuda.userId, space, "deudas");
    await ref.doc(deuda.id).update(deuda.toMap());
  }

  Future<void> deleteDeuda(Deuda d, bool space) async {
    final ref = _getCollection(d.userId, space, "deudas");
    await ref.doc(d.id).delete();
  }

  // ==========================================
  // 💸 SECCIÓN DE Ahorros ===================
  // ==========================================

  Future<void> addAhorro(Ahorro a, bool space) async {
    ////print("😶‍🌫️😶‍🌫️😶‍🌫️ 6");
    try {
      final ref = _getCollection(a.userId, space, "ahorros");
      // Usamos .set para asegurar que el ID sea el que generamos en la app
      await ref.doc(a.id).set(a.toMap());
    } catch (e) {
      ////print("❌ Error al guardar ahorro: $e");
      rethrow;
    }
    ////print("😶‍🌫️😶‍🌫️😶‍🌫️ 8 ID: ${a.userId}");
  }

  Stream<List<Ahorro>> getAhorrosStream(
    String userId,
    String? spaceId,
    bool isSpaceMode,
  ) {
    // Si estamos en modo space y hay ID, usamos el ID del space. Si no, null (personal).
    final targetId = (isSpaceMode && spaceId != null) ? spaceId : userId;

    final ref = _getCollection(
      targetId,
      (isSpaceMode && spaceId != null),
      "ahorros",
    );
    return ref.snapshots().map(_mapSnapshotToAhorros);
  }

  Future<void> updateAhorro(Ahorro a, bool space) async {
    final ref = _getCollection(a.userId, space, "ahorros");
    await ref.doc(a.id).update(a.toMap());
  }

  Future<void> deleteAhorro(Ahorro a, bool space) async {
    final ref = _getCollection(a.userId, space, "ahorros");
    ////print("💰💰💰 ${a.id}, $space, ahorros");
    await ref.doc(a.id).delete();
  }

  // ==========================================
  // 📩 SECCIÓN DE INVITACIONES
  // ==========================================

  Future<void> addInvitacion(Invitacion i) async {
    try {
      await _invitacionRef.doc(i.codeInvitacion).set(i.toMap());
    } catch (e) {
      //print("$e error bro")
    }
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
    } catch (e) {
      //print error bro
    }
  }

  // ✨ HELPER DE MAPEO
  List<Transaction> _mapSnapshotToTransactions(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Transaction.fromMap(data);
    }).toList();
  }

  List<Deuda> _mapSnapshotToDeudas(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Deuda.fromMap(data);
    }).toList();
  }

  List<Ahorro> _mapSnapshotToAhorros(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Ahorro.fromMap(data);
    }).toList();
  }
}
