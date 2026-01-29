import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:money_move/services/auth_service.dart';
import 'package:money_move/widgets/mode_toggle.dart';
import 'package:provider/provider.dart';

Drawer drawerUser(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;

  // 1. Usamos '?' para que no explote si por un milisegundo el usuario de Firebase es null
  final fbUser = FirebaseAuth.instance.currentUser;

  final userProv = Provider.of<UserProvider>(context);
  final tProv = Provider.of<TransactionProvider>(context);
  final strings = AppLocalizations.of(context)!;

  // 2. Extraemos el usuario de tu base de datos de forma segura
  final appUser = userProv.usuarioActual;

  // 3. Lógica SEGURA: Si appUser es null, appUser?.linkedAccountId devuelve null, y la condición es false. No explota.
  bool modoSpace = (tProv.isSpaceMode && appUser?.linkedAccountId != null);

  return Drawer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A. CABECERA CON DATOS DE GOOGLE
        UserAccountsDrawerHeader(
          // Usamos '??' para poner texto por defecto si fbUser es null
          accountName: Text(fbUser?.displayName ?? strings.userText),
          accountEmail: Text(fbUser?.email ?? strings.noEmailText),
          currentAccountPicture: CircleAvatar(
            backgroundImage: fbUser?.photoURL != null
                ? NetworkImage(fbUser!.photoURL!)
                : null,
            child: fbUser?.photoURL == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          decoration: BoxDecoration(
            color: modoSpace ? colorScheme.inversePrimary : colorScheme.primary,
          ),
        ),

        // 4. Verificación SEGURA para mostrar el toggle
        // Si appUser es null O linkedAccountId es null, mostramos SizedBox
        (appUser?.linkedAccountId == null)
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people_alt_outlined),
                        const SizedBox(width: 5),
                        Text(
                          "${strings.actualSpaceText}:",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const ModeToggle(bigWidget: true),
                  ],
                ),
              ),

        const Spacer(), // Empuja el botón de salida al final
        const Divider(),

        // C. BOTÓN DE SALIDA (LOGOUT)
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: Text(
            strings.logoutText,
            style: const TextStyle(color: Colors.red),
          ),
          onTap: () async {
            // 1. Llamamos al servicio para desconectar Google y Firebase
            await AuthService().logout();
          },
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}

class LeadingDrawer extends StatelessWidget {
  const LeadingDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Protección extra aquí también
    final user = FirebaseAuth.instance.currentUser;

    return Builder(
      builder: (context) {
        final String? fotoUrl = user?.photoURL;

        return IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          padding: EdgeInsets.zero,
          icon: CircleAvatar(
            radius: 18,
            backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
            child: fotoUrl == null ? const Icon(Icons.person, size: 20) : null,
          ),
        );
      },
    );
  }
}
