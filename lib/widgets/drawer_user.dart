import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/services/auth_service.dart';

Drawer drawerUser(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final user = FirebaseAuth.instance.currentUser!;

  return Drawer(
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
        // ListTile(
        //   leading: const Icon(Icons.sync),
        //   title: const Text("Sincronizar Datos"),
        //   onTap: () {
        //     // Aquí conectaremos la Base de Datos luego
        //     Navigator.pop(context);
        //   },
        // ),

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
