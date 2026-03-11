import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:money_move/providers/ahorro_provider.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/providers/space_provider.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/providers/ui_provider.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // --- LOGIN CON GOOGLE ---
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      print("🔍 DEBUG 1: Iniciando Google Sign-In...");

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("🔍 DEBUG 2: El usuario canceló o cerró la ventanita de Google.");
        return null;
      }

      print("🔍 DEBUG 3: Cuenta seleccionada: ${googleUser.email}");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("🔍 DEBUG 4: Credenciales obtenidas, conectando a Firebase...");
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      print(
        "🔍 DEBUG 5: ¡Login exitoso en Firebase para ${result.user?.email}!",
      );

      if (context.mounted) {
        print("🔍 DEBUG 6: Inicializando UserProvider...");
        final userProv = Provider.of<UserProvider>(context, listen: false);
        userProv.initSubscription();
      }

      print("🔍 DEBUG 7: ¡Todo listo, devolviendo credenciales!");
      return result;
    } catch (e) {
      print("🚨🚨🚨 ERROR FATAL EN LOGIN: $e"); // ESTO NOS DIRÁ LA VERDAD
      rethrow;
    }
  }

  // --- CERRAR SESIÓN ---
  // --- CERRAR SESIÓN ---
  Future<void> logout(BuildContext context) async {
    try {
      // TRUCO MÁGICO: Usar disconnect en lugar de signOut para Google
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      if (context.mounted) {
        Provider.of<UserProvider>(context, listen: false).clearData();
        Provider.of<TransactionProvider>(context, listen: false).clearData();
        Provider.of<DeudaProvider>(context, listen: false).clearData();
        Provider.of<AhorroProvider>(context, listen: false).clearData();
        Provider.of<SpaceProvider>(context, listen: false).clearData();
        Provider.of<UiProvider>(context, listen: false).clearData();
      }
      print("🚪 Logout completado al 100%");
    } catch (e) {
      print("🚨 Error durante el logout: $e");
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
