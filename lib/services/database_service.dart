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

  // ==========================================
  // 👤 SECCIÓN DE USERS
  // ==========================================

  Future<void> addUser(UserModel userData) async {
    try {
      await _userRef.doc(userData.uid).set(userData.toMap());
    } catch (e) {
      print("💀💀💀💀💀💀💀💀DataServise AddUser <---------");
      rethrow;
    }
  }

  // ==========================================
  // 💰 SECCIÓN DE TRANSACCIONES
  // ==========================================

  // --- AGREGAR ---
  Future<void> addTransaction(Transaction transaction) async {
    final CollectionReference _trasantionsRef = _userRef
        .doc(transaction.userId)
        .collection("transactions");

    try {
      // Usamos .set para que el ID del documento coincida con el ID interno (UUID)
      await _trasantionsRef.doc(transaction.id).set(transaction.toMap());
    } catch (e) {
      print("❌❌❌❌❌ Error al guardar transacción: $e");
      rethrow;
    }
  }

  // --- LEER ---
  Stream<List<Transaction>> getTransactionsStream(
    String userId,
    String? spaceId,
  ) {
    // ignore: no_leading_underscores_for_local_identifiers
    final CollectionReference _transactionsRef = _userRef
        .doc(userId)
        .collection("transactions");
    // 1. Tu lista (Stream A)
    Stream<List<Transaction>> myList = _transactionsRef.snapshots().map(
      _mapSnapshotToTransactions,
    );
    return myList.map((lista) {
      return lista;
    });
  }

  // --- ACTUALIZAR ---
  Future<void> updateTransaction(Transaction transaction) async {
    final CollectionReference _transactionsRef = _userRef
        .doc(transaction.userId)
        .collection("transactions");
    try {
      // Al usar el ID correcto (gracias al parche de arriba), esto ya no fallará
      await _transactionsRef.doc(transaction.id).update(transaction.toMap());
    } catch (e) {
      print("❌❌❌❌❌ Error al actualizar transacción: $e");
      rethrow;
    }
  }

  // --- BORRAR ---
  Future<void> deleteTransaction(String id) async {
    // ignore: no_leading_underscores_for_local_identifiers
    final CollectionReference _transactionsRef = _userRef
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("transactions");
    try {
      await _transactionsRef.doc(id).delete();
    } catch (e) {
      print("❌❌❌❌❌ Error al borrar transacción: $e");
    }
  }

  // ==========================================
  // 💸 SECCIÓN DE DEUDAS
  // ==========================================

  Future<void> addDeuda(Deuda deuda) async {
    final CollectionReference _deudasRef = _userRef
        .doc(deuda.userId)
        .collection("deudas");
    try {
      await _deudasRef.doc(deuda.id).set(deuda.toMap());
    } catch (e) {
      print("❌ Error al guardar deuda: $e");
      rethrow;
    }
  }

  Stream<List<Deuda>> getDeudasStream(String userId) {
    final CollectionReference _deudasRef = _userRef
        .doc(userId)
        .collection("deudas");
    return _deudasRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Aplicamos el mismo parche de seguridad a las deudas
        data['id'] = doc.id;
        return Deuda.fromMap(data);
      }).toList();
    });
  }

  Future<void> updateDeuda(Deuda deuda) async {
    final CollectionReference _deudasRef = _userRef
        .doc(deuda.userId)
        .collection("deudas");
    try {
      await _deudasRef.doc(deuda.id).update(deuda.toMap());
    } catch (e) {
      print("❌ Error al actualizar deuda: $e");
      rethrow;
    }
  }

  Future<void> deleteDeuda(String id, String userId) async {
    final CollectionReference _deudasRef = _userRef
        .doc(userId)
        .collection("deudas");
    try {
      await _deudasRef.doc(id).delete();
    } catch (e) {
      //print("❌ Error al borrar deuda: $e");
    }
  }

  // ==========================================
  // 👤 SECCIÓN DE invitaciones
  // ==========================================

  Future<void> addInvitacion(Invitacion i) async {
    try {
      await _invitacionRef.doc(i.codeInvitacion).set(i.toMap());
    } catch (e) {
      //print("❌ Error: $e");
    }
  }

  Future<Invitacion?> getActiveInvitationFuture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await _invitacionRef
        .where('creatorId', isEqualTo: user.uid)
        .limit(1)
        .get(); //Uso .get() en vez de .snapshots() para que sea Future y no stream xd

    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    return Invitacion.fromMap(data);
  }

  Future<void> deleteInvitacion(String id) async {
    try {
      await _invitacionRef.doc(id).delete();
    } catch (e) {
      //print("❌ Error: $e");
    }
  }

  // ✨ Función auxiliar para no escribir lo mismo 2 veces (DRY: Don't Repeat Yourself)
  List<Transaction> _mapSnapshotToTransactions(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Transaction.fromMap(data);
    }).toList();
  }
}
