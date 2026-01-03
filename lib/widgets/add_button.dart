import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
// import 'package:money_move/config/app_colors.dart'; // Ya no se necesita
import 'package:money_move/screens/add_deuda_screen.dart';
import 'package:money_move/screens/add_transaction_screen.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Acceso a los colores del tema
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 56, 
      width: 56,
      decoration: BoxDecoration(
        // Antes: AppColors.primaryLight
        // Ahora: colorScheme.primary (El color principal de tu app)
        color: colorScheme.primary, 
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        // El icono "+" debe contrastar con el fondo primario.
        // Usamos onPrimary (generalmente blanco).
        icon: Icon(Icons.add, color: colorScheme.onPrimary, size: 28),
        
        offset: const Offset(0, -120),
        
        // El color del fondo del menú emergente
        color: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint, // Pequeño tinte en Material 3

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        
        onSelected: (value) {
          _handleMenuSelection(context, value);
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: "transaccion",
            child: Row(
              children: [
                // Icono azulado/gris que combina con el tema
                Icon(Icons.receipt_long_rounded, color: colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.addTransaction,
                  // Texto adaptable: Negro (Día) / Blanco (Noche)
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: "deuda",
            child: Row(
              children: [
                // Usamos el color de error del tema para mantener coherencia (suele ser rojo)
                Icon(Icons.handshake_outlined, color: colorScheme.error),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.addDeuda,
                  style: TextStyle(color: colorScheme.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    if (value == "transaccion") {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
      );
    } else if (value == "deuda") {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddDeudaScreen()),
      );
    }
  }
}