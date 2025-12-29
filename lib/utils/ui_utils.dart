import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart'; // Importa tus textos

class UiUtils {
  // Método estático para usar en cualquier lado
  static void showDeleteConfirmation(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.areYouSureTitle), // "¿Estás seguro?"
        content: Text(AppLocalizations.of(context)!.accitionNotUndone), // "Esto no se puede deshacer"
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Cierra sin hacer nada
            child: Text(AppLocalizations.of(context)!.cancelText),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Cierra el popup
              onConfirm(); // EJECUTA LA LÓGICA QUE LE PASASTE (Borrar)
            },
            child: Text(
              AppLocalizations.of(context)!.deleteText,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}