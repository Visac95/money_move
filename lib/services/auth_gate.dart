import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/screens/login_screen.dart';
import 'package:money_move/screens/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // 1. LA TUBERÍA: Escuchamos a Firebase Auth
      stream: FirebaseAuth.instance.authStateChanges(),

      // 2. EL CONSTRUCTOR: Se ejecuta cada vez que cambia el estado (login/logout)
      builder: (context, snapshot) {
        // Caso A: ¿Está cargando la conexión inicial?
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Caso B: ¡Tenemos datos! (El usuario está logueado)
        if (snapshot.hasData) {
          return const MainScreen();
        }

        // Caso C: No hay datos (El usuario no está logueado)
        return const LoginScreen();
        // <--- Usaremos esto luego
      },
    );
  }
}
