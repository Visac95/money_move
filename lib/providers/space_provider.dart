import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/models/invitacion.dart';
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

  Future<void> deleteInvitacion(String id) async {
    _dbService.deleteInvitacion(id);
  }

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
      final String hostUid = inviteData['creatorId']; // ID de tu amigo
      final String spaceId = inviteData['spaceId']; // ID del nuevo grupo

      // Evitar que te unas a tu propia invitación (opcional)
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

      // 3. PREPARAR EL BATCH (El paquete todo-en-uno) 📦
      WriteBatch batch = firestore.batch();

      // A. Actualizar al DUEÑO (Host)
      final hostRef = firestore.collection('users').doc(hostUid);
      batch.update(hostRef, {
        'linkedAccountId': guestUser.uid, // Le decimos quién es su pareja
        'spaceId': spaceId, // Le asignamos el grupo
      });

      // B. Actualizar al INVITADO (Yo)
      final guestRef = firestore.collection('users').doc(guestUser.uid);
      batch.update(guestRef, {
        'linkedAccountId': hostUid, // Guardo quién es mi pareja
        'spaceId': spaceId, // Me asigno el grupo
      });

      // C. BORRAR LA INVITACIÓN 🗑️
      // Aquí es donde ocurre la magia. Como ya usamos los datos,
      // ordenamos que se autodestruya en el mismo momento que nos unimos.
      batch.delete(inviteRef);

      // 4. EJECUTAR TOdo
      await batch.commit();

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
