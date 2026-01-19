import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:money_move/models/deuda.dart';
import 'package:money_move/models/invitacion.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/models/user_model.dart';
import 'package:rxdart/rxdart.dart';

class DatabaseService {
  final CollectionReference _transactionsRef = FirebaseFirestore.instance
      .collection('transactions');

  final CollectionReference _deudasRef = FirebaseFirestore.instance.collection(
    'deudas',
  );

  final CollectionReference _usersRef = FirebaseFirestore.instance.collection(
    'users',
  );

  final CollectionReference _invitacionRef = FirebaseFirestore.instance
      .collection('invitations');

  // ==========================================
  // 👤 SECCIÓN DE USERS
  // ==========================================

  Future<void> addUser(UserModel userData) async {
    try {
      await _usersRef.doc(userData.uid).set(userData.toMap());
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
    try {
      // Usamos .set para que el ID del documento coincida con el ID interno (UUID)
      await _transactionsRef.doc(transaction.id).set(transaction.toMap());
    } catch (e) {
      //print("❌ Error al guardar transacción: $e");
      rethrow;
    }
  }

  // --- LEER ---
  Stream<List<Transaction>> getTransactionsStream(
    String userId,
    String? partnerUid,
  ) {
    // 1. Tu lista (Stream A)
    Stream<List<Transaction>> myList = _transactionsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          _mapSnapshotToTransactions,
        ); // ✨ Usamos una función auxiliar para no repetir código

    // 2. Verificamos si hay pareja
    if (partnerUid != null && partnerUid.isNotEmpty) {
      // Agregué isNotEmpty por seguridad

      // 3. Lista Pareja (Stream B)
      Stream<List<Transaction>> partnerList = _transactionsRef
          .where('userId', isEqualTo: partnerUid)
          .snapshots()
          .map(_mapSnapshotToTransactions);

      // 4. LA FUSIÓN ORDENADA
      return Rx.combineLatest2(myList, partnerList, (listaMia, listaPareja) {
        // A. Unimos
        var listaTotal = [...listaMia, ...listaPareja];
        return listaTotal;
      });
    } else {
      // Si está solo, también las ordenamos por si acaso
      return myList.map((lista) {
        return lista;
      });
    }
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
