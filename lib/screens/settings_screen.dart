import 'package:flutter/material.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:money_move/providers/settings_provider.dart';
import 'package:money_move/providers/locale_provider.dart';
import 'package:money_move/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Accedemos a las traducciones
    final strings = AppLocalizations.of(context)!;
    // Accedemos al provider de idioma
    final localeProv = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settingsTitle), // Usa traducción o texto default
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN IDIOMA ---
            _SectionHeader(title: strings.generalText, icon: Icons.settings),

            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.language),
                title: Text(strings.languageText),
                subtitle: Text(
                  _getLanguageName(localeProv.locale.languageCode),
                ),
                trailing: PopupMenuButton<Locale>(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onSelected: (Locale newLocale) {
                    // AQUÍ ESTÁ LA MAGIA: Cambiamos el idioma global
                    localeProv.changeLocale(newLocale);
                  },
                  itemBuilder: (context) => <PopupMenuEntry<Locale>>[
                    const PopupMenuItem(
                      value: Locale('es'),
                      child: Text("🇪🇸 Español"),
                    ),
                    const PopupMenuItem(
                      value: Locale('en'),
                      child: Text("🇺🇸 English"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- SECCIÓN PANTALLA ---
            _SectionHeader(
              title: strings.pantallaText,
              icon: Icons.palette_outlined,
            ),

            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(strings.darkModeText),
                    secondary: const Icon(
                      Icons.dark_mode_rounded,
                    ), // Icono a la izquierda
                    value: Provider.of<SettingsProvider>(context).isDarkMode,
                    onChanged: (bool value) {
                      Provider.of<SettingsProvider>(
                        context,
                        listen: false,
                      ).toggleTheme(value);
                    },
                  ),
                ],
              ),
            ),

            // En SettingsScreen, dentro del Column, al final
            const SizedBox(height: 30), // Un poco de espacio
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // Llamamos a la función sembradora
                  Provider.of<TransactionProvider>(
                    context,
                    listen: false,
                  ).generateMockData();

                  // Feedback visual (opcional)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Datos de prueba inyectados! 💉'),
                    ),
                  );
                },
                icon: const Icon(Icons.bug_report, color: Colors.grey),
                label: const Text(
                  "Generar Datos de Prueba",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pequeña función para mostrar el nombre bonito del idioma actual
  String _getLanguageName(String code) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return 'Español';
    }
  }
}

// Widget separado para los títulos de sección (Más limpio)
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
