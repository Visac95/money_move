import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/utils/mode_color_app_bar.dart';
import 'package:money_move/widgets/add_deuda_button.dart';
import 'package:money_move/widgets/lista_deudas_widget.dart';
import 'package:money_move/widgets/mode_toggle.dart';
import 'package:money_move/widgets/settings_button.dart';
import 'package:money_move/widgets/small_box_saldo.dart';

class AllDeudasScreen extends StatefulWidget {
  const AllDeudasScreen({super.key});

  @override
  State<AllDeudasScreen> createState() => _AllDeudasScreenState();
}

class _AllDeudasScreenState extends State<AllDeudasScreen> {
  @override
  Widget build(BuildContext context) {
    // Inicializamos la variable de localización
    final strings = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: modeColorAppbar(context),
        title: Row(
          children: [
            Icon(Icons.receipt_long),
            SizedBox(width: 5),
            Text(
              strings.titleDeudasScreen,
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
            _deudaTitle(strings.deudasPorPagarText, false),
            ListaDeudasWidget(deboList: true, pagada: false),
            _deudaTitle(strings.deudasPorCobrarText, false),
            ListaDeudasWidget(deboList: false, pagada: false),
            ExpansionTile(
              title: Text(
                strings.seeSettledDeudasText,
              ), // Texto que siempre se ve
              children: [
                _deudaTitle(strings.paidDeudasText, true),
                ListaDeudasWidget(deboList: true, pagada: true),
                _deudaTitle(strings.recivedDeudasText, true),
                ListaDeudasWidget(deboList: false, pagada: true),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: const AddDeudaButton(),
    );
  }

  Widget _deudaTitle(String title, bool pagado) {
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
