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

  //----------------------------------
  //-------📨 INVITACIONES ------------
  //----------------------------------

  Invitacion? _invitacion;

  Invitacion? get invitacion => _invitacion;

  Future<Invitacion?> generateInvitacion() async {
    final user = FirebaseAuth.instance.currentUser;

    // 1. Seguridad: Si no hay usuario, no hacemos nada.
    if (user == null) {
      return null;
    }

    try {
      Invitacion? invitacionExistente = await _dbService
          .getActiveInvitationFuture();

      if (invitacionExistente != null) {
        if (invitacionExistente.creationDate.sigueVigente) {
          _invitacion = invitacionExistente;
          return _invitacion;
        }

        await _dbService.deleteInvitacion(invitacionExistente.codeInvitacion);
      }

      String shortCode = generarCodigoCorto();
      String spaceId = const Uuid().v4();
      
      String linkInvitacion =
          "https://moneymove.visacstudio.online/invite?code=$shortCode";

      _invitacion = Invitacion(
        codeInvitacion: shortCode,
        linkInvitacion: linkInvitacion,
        creationDate: DateTime.now(),
        creatorId: user.uid,
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
          print("No se pudo borrar la invitación expirada (probablemente permisos)");
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

      print("📨✅ Space Creado Exitosamente");

      notifyListeners();

      return InvitacionStatus.success;
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
        print("Código inválido o expirado🤐🫤☹️");
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

      final String? partnerUid = guestUser.linkedAccountId;
      final String? spaceId = guestUser.spaceId;

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

      await batch.commit();
      
      // Intentamos borrar el space (si las reglas lo permiten)
      await firestore.collection("spaces").doc(spaceId).delete();
      print("📨✅ Space eliminado y usuarios desvinculados");

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
  StreamSubscription<DocumentSnapshot>? _spaceSubscription;

  Space? get currentSpace => _currentSpace;
  bool get isInSpace => _currentSpace != null;

  // 🔥 NUEVO: VARIABLES PARA EL MODO DE VISTA (Personal vs Space)
  // ------------------------------------------------------------
  bool _isSpaceMode = false;
  bool get isSpaceMode => _isSpaceMode;

  // 🔥 NUEVO: Función para cambiar el modo desde el Switch
  void setSpaceMode(bool value) {
    // Seguridad: No puedes activar modo space si no tienes space
    if (value == true && _currentSpace == null) {
      _isSpaceMode = false;
    } else {
      _isSpaceMode = value;
    }
    notifyListeners();
  }
  // ------------------------------------------------------------

  void initSpaceSubscription(String? spaceId) {
    _spaceSubscription?.cancel();
    _spaceSubscription = null;

    // VALIDACIÓN:
    // Si el usuario no tiene spaceId (es null), limpiamos todo.
    if (spaceId == null || spaceId.isEmpty) {
      _currentSpace = null;
      _isSpaceMode = false; // 🔥 Aseguramos que vuelva a modo personal
      notifyListeners();
      return;
    }

    print("🛰️✅✅ SpaceProvider: Conectando al espacio $spaceId...");

    // SUSCRIPCIÓN:
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
              _isSpaceMode = false; // 🔥 Si borran el grupo, volvemos a personal
            }
            notifyListeners();
          },
          onError: (error) {
            print("🚨 Error escuchando el space: $error");
          },
        );
  }

  // Método para limpiar todo (Logout o Salir del grupo)
  void clearSpace() {
    print("🧹 SpaceProvider: Limpiando espacio local");
    _spaceSubscription?.cancel();
    _spaceSubscription = null;
    _currentSpace = null;
    _isSpaceMode = false; // 🔥 Apagamos el modo Space al salir
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