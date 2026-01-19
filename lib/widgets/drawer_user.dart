import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/space_provider.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:money_move/services/auth_service.dart';
import 'package:money_move/widgets/mode_toggle.dart';
import 'package:provider/provider.dart';

Drawer drawerUser(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final user = FirebaseAuth.instance.currentUser!;
  final userProv = Provider.of<UserProvider>(context);
  final spaceProv = Provider.of<SpaceProvider>(context);
  final strings = AppLocalizations.of(context)!;

  return Drawer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A. CABECERA CON DATOS DE GOOGLE
        UserAccountsDrawerHeader(
          accountName: Text(
            user.displayName ?? "Usuario",
            style: TextStyle(color: colorScheme.surface),
          ),
          accountEmail: Text(
            user.email ?? "Sin correo",
            style: TextStyle(color: colorScheme.surface),
          ),
          currentAccountPicture: CircleAvatar(
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
            child: user.photoURL == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          decoration: BoxDecoration(
            color: spaceProv.isSharedMode
                ? colorScheme.inversePrimary
                : colorScheme.primary,
          ),
        ),
        
        userProv.usuarioActual!.linkedAccountId == null
            ? SizedBox()
            : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Row(
                  children: [
                    
                    Icon(Icons.people_alt_outlined),
                    SizedBox(width: 5,),
                    Text("${strings.actualSpaceText}:", style: TextStyle(fontSize: 16),),
                  ],
                ), 
                SizedBox(height: 5,),
                ModeToggle()]),
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
    final user = FirebaseAuth.instance.currentUser!;
    return Builder(
      builder: (context) {
        // Supongamos que tienes tu usuario aquí
        // (Ojo: accede a tu Provider o variable donde tengas el user)
        final String? fotoUrl = user.photoURL;

        return IconButton(
          // Al tocar la foto, abrimos el Drawer
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
