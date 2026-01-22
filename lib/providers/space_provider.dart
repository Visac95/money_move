import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/models/invitacion.dart';
import 'package:money_move/models/space.dart';
import 'package:money_move/models/user_model.dart';
import 'package:money_move/services/database_service.dart';
import 'package:money_move/utils/generar_codigo_corto.dart';
import 'package:uuid/uuid.dart';

class SpaceProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  bool _isSharedMode = false;

  bool get isSharedMode => _isSharedMode;

  void toogleMode() {
    _isSharedMode = !_isSharedMode;
    notifyListeners();
  }

  void setSharedMode(bool value) {
    _isSharedMode = value;
    notifyListeners();
  }

  //----------------------------------
  //-------📨 INVITACIONES ------------
  //----------------------------------

  Invitacion? _invitacion;

  Invitacion? get invitacion => _invitacion;

  Future<Invitacion?> generateInvitacion() async {
    final user = FirebaseAuth.instance.currentUser;

    // 1. Seguridad: Si no hay usuario, no hacemos nada.
    if (user == null) {
      //print("Error: No hay usuario logueado");
      return null;
    }

    try {
      Invitacion? invitacionExistente = await _dbService
          .getActiveInvitationFuture();

      if (invitacionExistente != null) {
        if (invitacionExistente.creationDate.sigueVigente) {
          _invitacion = invitacionExistente;
          //print("♻️ Reutilizando invitación activa");
          return _invitacion;
        }

        await _dbService.deleteInvitacion(invitacionExistente.codeInvitacion);
      }

      String shortCode = generarCodigoCorto();
      String spaceId = const Uuid().v4();
      // Tip: Usa Uri.encodeComponent por si acaso, aunque con tu generador no hace falta.
      String linkInvitacion =
          "https://moneymove.visacstudio.online/invite?code=$shortCode";

      _invitacion = Invitacion(
        codeInvitacion: shortCode,
        linkInvitacion: linkInvitacion,
        creationDate: DateTime.now(),
        creatorId: user.uid, // Ya validamos arriba que user no es null
        spaceId: spaceId,
      );

      await _dbService.addInvitacion(_invitacion!);
      print("✨ Nueva invitación creada: $shortCode");

      return _invitacion;
    } catch (e) {
      print("Error generando invitación: $e");
      return null;
    }
  }

  //------------BORRAR INVITACIÓN-----------
  //----------------------------------------
  Future<void> deleteInvitacion(String id) async {
    _dbService.deleteInvitacion(id);
  }

  //------------Entrar al space-----------
  //----------------------------------------
  Future<InvitacionStatus> joinSpace(String codeInput) async {
    final firestore = FirebaseFirestore.instance;
    final guestUser = FirebaseAuth.instance.currentUser;

    if (guestUser == null) {
      print("No hay usuario logueado💀💀💀");
      return InvitacionStatus.noUser;
    }
    ;

    try {
      final inviteRef = firestore.collection('invitations').doc(codeInput);
      final inviteSnapshot = await inviteRef.get();

      if (!inviteSnapshot.exists) {
        print("Código inválido");
        return InvitacionStatus.invalid;
      }

      final inviteData = inviteSnapshot.data()!;
      final i = Invitacion.fromMap(inviteData);
      final String hostUid = inviteData['creatorId'];
      final String spaceId = inviteData['spaceId'];

      if (hostUid == guestUser.uid) {
        print("No puedes unirte a tu propia invitación");
        return InvitacionStatus.selfInvitacion;
      }

      if (!i.creationDate.sigueVigente) {
        print("Ya expiro la invitacion");
        try {
          await deleteInvitacion(i.codeInvitacion);
        } catch (_) {
          print(
            "No se pudo borrar la invitación expirada (probablemente permisos)",
          );
        }
        return InvitacionStatus.expired;
      }

      WriteBatch batch = firestore.batch();

      final hostRef = firestore.collection('users').doc(hostUid);
      batch.update(hostRef, {
        'linkedAccountId': guestUser.uid,
        'spaceId': spaceId,
      });

      final guestRef = firestore.collection('users').doc(guestUser.uid);
      batch.update(guestRef, {'linkedAccountId': hostUid, 'spaceId': spaceId});

      batch.delete(inviteRef);

      await batch.commit();
      _invitacion = null;

      await firestore.collection("spaces").doc(spaceId).set({
        'id': spaceId,
        'createdAt': DateTime.now(),
        'members': [hostUid, guestUser.uid],
      });

      print("📨✅📨✅📨✅ ${firestore.collection("spaces").doc(spaceId).get()}");

      notifyListeners();

      return InvitacionStatus.success; // Éxito total
    } catch (e) {
      print("💀💀💀💀💀Error al unirse: $e");
      return InvitacionStatus.error;
    }
  }

  Future<(Invitacion?, InvitacionStatus)> getInvitacionByCode(
    String code,
  ) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) return (null, InvitacionStatus.noUser);

      final userSnapshot = await firestore
          .collection("users")
          .doc(authUser.uid)
          .get();

      if (!userSnapshot.exists) return (null, InvitacionStatus.error);

      final guestUser = UserModel.fromFirestore(userSnapshot);

      if (guestUser.spaceId != null) {
        print("El usuario ya pertenece a un Space");
        return (null, InvitacionStatus.alreadyInSpace);
      }

      final inviteRef = firestore.collection('invitations').doc(code);
      final inviteSnapshot = await inviteRef.get();

      if (!inviteSnapshot.exists) {
        print("Código inválido o expirado");
        return (null, InvitacionStatus.expired);
      }

      final inviteData = inviteSnapshot.data()!;
      final i = Invitacion.fromMap(inviteData);

      if (i.creatorId == guestUser.uid) {
        print("No puedes unirte a tu propia invitación");
        return (null, InvitacionStatus.selfInvitacion);
      }

      if (!i.creationDate.sigueVigente) {
        print("Ya expiro la invitacion");
        await deleteInvitacion(i.codeInvitacion);
        return (null, InvitacionStatus.expired);
      }

      return (i, InvitacionStatus.success);
    } catch (e) {
      print("💀💀💀 getInvitacionByCode $e");
      return (null, InvitacionStatus.error);
    }
  }

  //------------Salir del space-----------
  //----------------------------------------
  Future<bool> exitSpace() async {
    try {
      final firestore = FirebaseFirestore.instance;

      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) return false;

      final userSnapshot = await firestore
          .collection("users")
          .doc(authUser.uid)
          .get();

      if (!userSnapshot.exists) return false;

      final guestUser = UserModel.fromFirestore(userSnapshot);

      final String? partnerUid = guestUser.linkedAccountId; // ID de tu amigo
      final String? spaceId = guestUser.spaceId; // ID del nuevo grupo

      if (partnerUid == null) return false;
      if (spaceId == null) {
        print("😍🫶😊 El usuario no pertenece a un Space");
        return false;
      }

      WriteBatch batch = firestore.batch();

      final hostRef = firestore.collection('users').doc(partnerUid);
      batch.update(hostRef, {'linkedAccountId': null, 'spaceId': null});

      final guestRef = firestore.collection('users').doc(guestUser.uid);
      batch.update(guestRef, {'linkedAccountId': null, 'spaceId': null});

      //batch.delete(inviteRef);

      await batch.commit();
      await firestore.collection("spaces").doc(spaceId).delete();
      print("📨✅📨✅📨✅ ${firestore.collection("spaces").doc(spaceId).get()}");

      clearSpace();
      notifyListeners();
      return true;
    } catch (e) {
      print("💀😍❤️🤑💀 Space Provider ExitSpace $e");
    }

    return false;
  }

  //----------------------------------------
  //------------SECCION SPACE GROUP-----------
  //----------------------------------------

  Space? _currentSpace;
  StreamSubscription<DocumentSnapshot>?
  _spaceSubscription; // Variable para controlar el grifo

  Space? get currentSpace => _currentSpace;
  bool get isInSpace => _currentSpace != null;

  // 1. Recibimos el ID directamente. No lo buscamos.
  void initSpaceSubscription(String? spaceId) {
    _spaceSubscription?.cancel();
    _spaceSubscription = null;

    // B. VALIDACIÓN:
    // Si el usuario no tiene spaceId (es null), limpiamos el modelo y nos vamos.
    if (spaceId == null || spaceId.isEmpty) {
      _currentSpace = null;
      notifyListeners();
      return;
    }

    print("🛰️✅✅ SpaceProvider: Conectando al espacio $spaceId...");

    // C. SUSCRIPCIÓN:
    _spaceSubscription = FirebaseFirestore.instance
        .collection("spaces")
        .doc(spaceId)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              print("✅ Datos del espacio recibidos/actualizados");
              _currentSpace = Space.fromMap(snapshot.data()!);
            } else {
              print("⚠️ El documento del espacio no existe (¿Fue borrado?)");
              _currentSpace = null;
            }
            notifyListeners(); // Avisamos a la UI para que redibuje
          },
          onError: (error) {
            print("🚨 Error escuchando el space: $error");
          },
        );
  }

  // 2. Método para limpiar todo (Logout o Salir del grupo)
  void clearSpace() {
    print("🧹 SpaceProvider: Limpiando espacio local");
    _spaceSubscription?.cancel(); // IMPORTANTE: Cortar la conexión
    _spaceSubscription = null;
    _currentSpace = null;
    notifyListeners();
  }
}

enum InvitacionStatus {
  noUser,
  invalid,
  expired,
  selfInvitacion,
  success,
  error,
  alreadyInSpace,
}

extension DateChecks on DateTime {
  bool get sigueVigente {
    final fechaVencimiento = this.add(const Duration(hours: 24));
    return DateTime.now().isBefore(fechaVencimiento);
  }
}
