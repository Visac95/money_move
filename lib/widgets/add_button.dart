import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/screens/add_deuda_screen.dart';
import 'package:money_move/screens/add_transaction_screen.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos un Container decorado para simular un FAB
    // Esto permite que el PopupMenuButton sea el dueño del click
    return Container(
      height: 56, // Tamaño estándar de un FAB
      width: 56,
      decoration: BoxDecoration(
        color: AppColors.primaryLight, // Tu color principal
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        // El icono "+" blanco
        icon: const Icon(Icons.add, color: AppColors.transactionListIconColor, size: 28),
        
        // Ajustamos la posición para que el menú salga un poco más arriba
        offset: const Offset(0, -120), 
        
        // Forma redondeada del menú
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        
        onSelected: (value) {
          _handleMenuSelection(context, value);
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: "transaccion", // Ojo con la ortografía aquí
            child: Row(
              children: [
                Icon(Icons.receipt_long_rounded, color: Colors.blueGrey),
                SizedBox(width: 10),
                Text("Nueva Transacción"),
              ],
            ),
          ),
          const PopupMenuItem(
            value: "deuda",
            child: Row(
              children: [
                Icon(Icons.handshake_outlined, color: Colors.redAccent),
                SizedBox(width: 10),
                Text("Nueva Deuda", style: TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    // Aquí tenías un error: 'trasnaccion' vs 'transaccion'
    if (value == "transaccion") {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
      );
      print("Ir a Transacción");
    } else if (value == "deuda") {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddDeudaScreen()),
      );
    }
  }
}