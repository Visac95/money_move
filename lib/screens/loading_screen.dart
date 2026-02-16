import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usa el color de fondo de tu tema o blanco/negro según prefieras
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              '/assets/logo.png', // ⚠️ CAMBIA ESTO por tu ruta real
              width: 100,
              height: 100,
              errorBuilder: (c, o, s) =>
                  const Icon(Icons.account_balance_wallet, size: 80),
            ),
            const SizedBox(height: 30),
            // LA BOLITA GIRANDO
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              strings.loadingFinancesText,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
