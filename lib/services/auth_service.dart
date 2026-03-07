import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // --- LOGIN CON GOOGLE ---
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      // 1. Disparar el flujo de autenticación nativo (abre la ventanita de elegir cuenta)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Si el usuario cancela la ventana, devolvemos null
      if (googleUser == null) return null;

      // 2. Obtener los detalles de autenticación de la petición
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Crear una credencial nueva para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Iniciar sesión en Firebase con esa credencial
      // (Esto es lo que dispara el cambio en el AuthGate)
      if (context.mounted) {
        final userProv = Provider.of<UserProvider>(context, listen: false);
        userProv.initSubscription();
      }

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      //print("Error en Google Sign-In: $e");
      rethrow; // Pasamos el error para que la pantalla lo muestre
    }
  }

  // --- CERRAR SESIÓN ---
  Future<void> logout(BuildContext context) async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    if (context.mounted) {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      userProv.stopSubscription();
    }
  }

  // 1. Iniciar sesión con Correo y Clave
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (_) {
      // Aquí puedes manejar errores específicos (contraseña errónea, usuario no existe)
      rethrow; // Lanzamos el error para mostrarlo en la pantalla
    }
  }

  // 2. Registrarse (Crear cuenta nueva)
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (_) {
      rethrow;
    }
  }
}
