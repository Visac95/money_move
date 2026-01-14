import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:money_move/config/app_colors.dart'; // <-- Ya no lo necesitas aquí
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/services/auth_service.dart';

import 'package:money_move/widgets/add_button.dart';
import 'package:money_move/widgets/balance_card.dart';
import 'package:money_move/widgets/ultimas_deudas.dart';
import 'package:money_move/widgets/ultimas_transacciones.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tProvider = Provider.of<TransactionProvider>(context);

    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: Text(
          AppLocalizations.of(context)!.appTitle,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // A. CABECERA CON DATOS DE GOOGLE
            UserAccountsDrawerHeader(
              accountName: Text(user.displayName ?? "Usuario"),
              accountEmail: Text(user.email ?? "Sin correo"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : null,
                child: user.photoURL == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              decoration: BoxDecoration(color: colorScheme.primary),
            ),

            // B. OPCIONES DEL MENÚ
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text("Sincronizar Datos"),
              onTap: () {
                // Aquí conectaremos la Base de Datos luego
                Navigator.pop(context); // Cierra el menú
              },
            ),

            const Spacer(), // Empuja el botón de salida al final
            const Divider(),

            // C. BOTÓN DE SALIDA (LOGOUT)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Cerrar Sesión",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                // 1. Llamamos al servicio para desconectar Google y Firebase
                await AuthService().logout();

                // 2. NO navegamos manualmente.
                // El AuthGate detectará que user es null y te mandará al Login solo.
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            BalanceCard(
              totalAmount: tProvider.saldoActual,
              expenseAmount: tProvider.totalEgresos,
              incomeAmount: tProvider.totalIngresos,
              withFilterButton: false,
            ),
            UltimasTransacciones(),
            UltimasDeudas(),
          ],
        ),
      ),
      floatingActionButton: const AddButton(),
    );
  }
}
