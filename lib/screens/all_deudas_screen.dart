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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(l10n.titleDeudasScreen), // <--- CAMBIO AQUÍ
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ListaDeudasWidget(deboList: true),
            ListaDeudasWidget(deboList: false),
          ],
        ),
      ),
      floatingActionButton: const AddDeudaButton(),
    );
  }
}
