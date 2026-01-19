import 'package:flutter/material.dart';
import 'package:money_move/models/user_model.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:money_move/screens/shared_intro_screen.dart';
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
    final user = Provider.of<UserProvider>(context).usuarioActual;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settingsTitle), // Usa traducción o texto default
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            //------Profile Information-----------
            _profileContainer(colorScheme, user, strings, context),
            _SectionHeader(title: strings.profileText, icon: Icons.person),
            _navigationCardOption(
              context,
              strings.sharedSpaceText,
              strings.sharedSpaceDescriptionText,
              SharedIntroScreen(),
              Icons.people_alt_outlined,
            ),
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
                title: Text(
                  strings.languageText,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                    title: Text(
                      strings.darkModeText,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
          ],
        ),
      ),
    );
  }

  Card _navigationCardOption(
    BuildContext context,
    String title,
    String subtitle,
    dynamic screen,
    IconData icon,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: IconButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => screen)),
          icon: Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  Widget _profileContainer(
    ColorScheme colorScheme,
    UserModel? user,
    AppLocalizations strings,
    BuildContext context,
  ) {
    // Detectamos si es modo oscuro para ajustar la sombra
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      // Usamos Stack para poder poner el botón de editar encima
      child: Stack(
        children: [
          // 1. LA TARJETA PRINCIPAL
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme
                  .surface, // O surfaceContainer si quieres más contraste
              borderRadius: BorderRadius.circular(24),
              // Sombra suave estilo iOS/Material 3 (Solo en modo claro)
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                // 2. EL AVATAR CON BORDE
                Container(
                  padding: const EdgeInsets.all(4), // Espacio para el borde
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50, // Un pelín más pequeño para balancear
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: colorScheme.onSurfaceVariant,
                          )
                        : null,
                  ),
                ),

                const SizedBox(height: 16),

                // 3. NOMBRE (Grande y fuerte)
                Text(
                  user?.name ?? "Usuario",
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 22, // Más grande
                    fontWeight: FontWeight.w800, // Más gordita la letra
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 4),

                // 4. EMAIL (Discreto)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.email ?? strings.emailText,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. BOTÓN DE EDITAR (Flotando arriba a la derecha)
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              onPressed: () {
                // Aquí podrías navegar a una pantalla de "Editar Perfil"
                // Navigator.pushNamed(context, '/edit_profile');
              },
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.primary,
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
          ),
        ],
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
