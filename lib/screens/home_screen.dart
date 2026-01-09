import 'package:flutter/material.dart';
// import 'package:money_move/config/app_colors.dart'; // <-- Ya no lo necesitas aquí
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/locale_provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        // Opcional: Si quieres la AppBar transparente como en la otra pantalla
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: Text(
          AppLocalizations.of(context)!.appTitle,
          style: TextStyle(
            color: colorScheme.onSurface, // Texto Negro (Día) / Blanco (Noche)
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final provider = context.read<LocaleProvider>();
              final currentLocale = Localizations.localeOf(context);

              // Lógica de cambio de idioma intacta
              if (currentLocale.languageCode == 'en') {
                provider.setLocale(const Locale('es'));
                _showSnackBar(
                  context,
                  AppLocalizations.of(context)!.changeLanguage,
                );
              } else {
                provider.setLocale(const Locale('en'));
                _showSnackBar(
                  context,
                  AppLocalizations.of(context)!.changeLanguage,
                );
              }
            },
            // El icono cambia de color según el tema
            icon: Icon(Icons.language, color: colorScheme.onSurface),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: const [
            // Agregué const para optimizar rendimiento
            BalanceCard(),
            UltimasTransacciones(),
            UltimasDeudas(),
          ],
        ),
      ),
      floatingActionButton: const AddButton(),
    );
  }

  // Helper pequeño para no repetir código del SnackBar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
