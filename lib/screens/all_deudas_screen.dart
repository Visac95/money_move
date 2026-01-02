import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart'; // <--- TU IMPORT CORRECTO
import 'package:money_move/widgets/add_deuda_button.dart';
import 'package:money_move/widgets/lista_deudas_widget.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(strings.titleDeudasScreen), // <--- CAMBIO AQUÍ
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _deudaTitle(strings.deudasPorPagarText),
            ListaDeudasWidget(deboList: true, pagada: false,),
            _deudaTitle(strings.deudasPorCobrarText),
            ListaDeudasWidget(deboList: false, pagada: false,),
            _deudaTitle("Deudas pagadas"),
            ListaDeudasWidget(deboList: true, pagada: true,),
            _deudaTitle("Deudas pagadas"),
            ListaDeudasWidget(deboList: false, pagada: true,),
          ],
        ),
      ),
      floatingActionButton: const AddDeudaButton(),
    );
  }

  Widget _deudaTitle (String title){
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
                  Icons.handshake_rounded, // Icono diferente a "history" para diferenciarlo
                  color: colorScheme.outline,
                  size: 20,
                ),
              ],
            ),
          );
  }
}
