import 'package:flutter/material.dart';
import 'package:money_move/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SwitchListTile(
        title: const Text("Modo Oscuro"),
        // Leemos el valor actual
        value: Provider.of<SettingsProvider>(context).isDarkMode,
        onChanged: (bool value) {
          // Ejecutamos el cambio
          Provider.of<SettingsProvider>(
            context,
            listen: false,
          ).toggleTheme(value);
        },
      ),
    );
  }
}
