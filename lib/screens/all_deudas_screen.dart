import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart'; // <--- TU IMPORT CORRECTO
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/widgets/add_deuda_button.dart';
import 'package:money_move/widgets/lista_deudas_widget.dart';
import 'package:provider/provider.dart';

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
    final saldo = Provider.of<TransactionProvider>(context).saldoActual;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          strings.titleDeudasScreen,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                // Fondo suave basado en tu color primario
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  // Icono opcional para dar contexto
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "\$${saldo.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
