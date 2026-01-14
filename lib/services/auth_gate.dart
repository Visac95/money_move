import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/screens/login_screen.dart';
import 'package:money_move/screens/main_screen.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // 1. LA TUBERÍA: Escuchamos a Firebase Auth
      stream: FirebaseAuth.instance.authStateChanges(),

      // 2. EL CONSTRUCTOR: Se ejecuta cada vez que cambia el estado (login/logout)
      builder: (context, snapshot) {
        // Caso A: ¿Está cargando la conexión inicial? (Opcional, pero se ve pro)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Caso B: ¡Tenemos datos! (El usuario está logueado)
        if (snapshot.hasData) {
          Provider.of<TransactionProvider>(
            context,
            listen: false,
          ).initSubscription();
          Provider.of<DeudaProvider>(context, listen: false).initSubscription();
          return const MainScreen();
          // <--- Pasa al Home
        }

        // Caso C: No hay datos (El usuario no está logueado)
        // Como aún no tenemos LoginScreen, por ahora pondremos un "Placeholder"
        // para que no te de error el código.
        return const LoginScreen();
        // <--- Usaremos esto luego
      },
    );
  }
}
