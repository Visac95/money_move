import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/models/invitacion.dart';
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
    try {
      final user = FirebaseAuth.instance.currentUser;

      String shortCode = generarCodigoCorto();
      String spaceId = const Uuid().v4();
      String linkInvitacion = "https://moneymove.app/join?c=$shortCode";

      _invitacion = Invitacion(
        codeInvitacion: shortCode,
        linkInvitacion: linkInvitacion,
        creationDate: DateTime.now(),
        creatorId: user!.uid,
        spaceId: spaceId,
      );
      await _dbService.addInvitacion(_invitacion!);
      return invitacion;
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

    if (guestUser == null) return InvitacionStatus.noUser;

    try {
      // 1. BUSCAR LA INVITACIÓN
      // Usamos el código ingresado como ID del documento (porque así lo guardamos antes)
      final inviteRef = firestore.collection('invitations').doc(codeInput);
      final inviteSnapshot = await inviteRef.get();

      // Validar si existe
      if (!inviteSnapshot.exists) {
        print("Código inválido o expirado");
        return InvitacionStatus.expired;
      }

      // 2. EXTRAER DATOS
      // Convertimos el snapshot a tu modelo (o sacamos los datos raw)
      final inviteData = inviteSnapshot.data()!;
      final String hostUid = inviteData['creatorId']; // ID de tu amigo
      final String spaceId = inviteData['spaceId']; // ID del nuevo grupo

      // Evitar que te unas a tu propia invitación (opcional)
      if (hostUid == guestUser.uid) {
        print("No puedes unirte a tu propia invitación");
        return InvitacionStatus.selfInvitacion;
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

      // 4. EJECUTAR TODO
      await batch.commit();

      return InvitacionStatus.success; // Éxito total
    } catch (e) {
      print("Error al unirse: $e");
      return InvitacionStatus.error;
    }
  }
}
enum InvitacionStatus {
  noUser,
  expired,
  selfInvitacion,
  success,
  error
}
