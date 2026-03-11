import 'dart:async'; // Necesario para StreamSubscription
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/models/user_model.dart';
import 'package:money_move/services/database_service.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  UserModel? _usuarioActual; // Puede empezar nulo

  // Guardamos la suscripción para poder controlarla
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  UserModel? get usuarioActual => _usuarioActual;

  void initSubscription() {
    final user = FirebaseAuth.instance.currentUser;

    // 1. SEGURIDAD: Si no hay usuario logueado o YA estamos escuchando, no hacemos nada.
    // Esto evita el spam de logs y duplicidad.
    if (user == null) return;
    if (_userSubscription != null) return;

    //print("🎧 Iniciando suscripción al usuario: ${user.uid}");

    _userSubscription = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.exists) {
              final newUser = UserModel.fromFirestore(snapshot);

              if (_usuarioActual?.spaceId != null && newUser.spaceId == null) {
                //print("💔💔💔💔💔💔 Me han sacado del grupo");
              }

              _usuarioActual = newUser; // Actualizamos
              notifyListeners();
            } else {
              //print("💀 Usuario no existe en DB, creándolo...");
              // Si no existe, lo creamos
              final newUser = UserModel(
                uid: user.uid,
                email: user.email ?? "",
                name: user.displayName ?? "Usuario",
                photoUrl: user.photoURL,
              );

              _dbService.addUser(newUser);
              // No hace falta notifyListeners aquí porque al crearlo,
              // Firebase disparará este listener de nuevo con 'exists' en true.
            }
          },
          onError: (error) {
            //print("🚨 Error en el listener del usuario: $error");
          },
        );
  }

  // Método para cerrar la escucha cuando cierras sesión (importante)
  // --------------------------------------------------------
  // RESETEO DE DATOS (Para cerrar sesión de forma segura)
  // --------------------------------------------------------
  void clearData() {
    _userSubscription?.cancel();
    _userSubscription = null;
    _usuarioActual = null;
    
    notifyListeners();
    //print("🧹 UserProvider reseteado exitosamente.");
  }

  Future<UserModel?> getUserByUid(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      //print("Error obteniendo usuario por UID: $e");
      return null;
    }
  }
}
