import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            onPressed: () {
              final provider = context.read<LocaleProvider>();
              final currentLocale = Localizations.localeOf(context);

              // Si es inglés cambia a español, si no, a inglés
              if (currentLocale.languageCode == 'en') {
                provider.setLocale(const Locale('es'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.changeLanguage,
                    ),
                  ),
                );
              } else {
                provider.setLocale(const Locale('en'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.changeLanguage,
                    ),
                  ),
                );
              }
            },
            icon: Icon(Icons.language),
          ),
        ],
      ),
      body: Column(
        children: [BalanceCard(), UltimasTransacciones(), UltimasDeudas()],
      ),
      floatingActionButton: AddButton(),
    );
  }
}
