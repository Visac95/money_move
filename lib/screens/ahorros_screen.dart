import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/screens/add_ahorro_screen.dart';
import 'package:money_move/utils/mode_color_app_bar.dart';
import 'package:money_move/widgets/add_dynamic_button_widget.dart';
import 'package:money_move/widgets/lista_deudas_widget.dart';
import 'package:money_move/widgets/mode_toggle.dart';
import 'package:money_move/widgets/settings_button.dart';
import 'package:money_move/widgets/small_box_saldo.dart';

class AhorrosScreen extends StatefulWidget {
  const AhorrosScreen({super.key});

  @override
  State<AhorrosScreen> createState() => _AhorrosScreenState();
}

class _AhorrosScreenState extends State<AhorrosScreen> {
  @override
  Widget build(BuildContext context) {
    // Inicializamos la variable de localización
    final strings = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: modeColorAppbar(context, 0.4),
        title: Row(
          children: [
            Icon(Icons.receipt_long),
            SizedBox(width: 5),
            Text(
              strings.titleAhorrosScreen,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          smallBoxSaldo(context, colorScheme),
          SizedBox(width: 5),
          ModeToggle(bigWidget: false),
          settingsButton(context),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _ahorroTitle(strings.deudasPorPagarText, false),
            ExpansionTile(
              title: Text(
                strings.seeSettledAhorrosText,
              ), // Texto que siempre se ve
              children: [
                _ahorroTitle(strings.paidDeudasText, true),
                ListaDeudasWidget(deboList: true, pagada: true),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: AddDynamicButtonWidget(screen: AddAhorroScreen()),
    );
  }

  Widget _ahorroTitle(String title, bool pagado) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Icon(
            pagado
                ? Icons.check_circle
                : Icons
                      .handshake_rounded, // Icono diferente a "history" para diferenciarlo
            color: colorScheme.outline,
            size: 20,
          ),
        ],
      ),
    );
  }
}
