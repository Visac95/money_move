import 'package:flutter/material.dart';
import 'package:money_move/providers/space_provider.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

Widget smallBoxSaldo(BuildContext context, ColorScheme colorScheme) {
  final tProv = Provider.of<TransactionProvider>(context);
  final saldo = tProv.saldoActual;
  final sProv = Provider.of<SpaceProvider>(context);
  return sProv.isInSpace
      ? _saldoCard(colorScheme, saldo, colorScheme.onSurface)
      : _saldoCard(colorScheme, saldo, colorScheme.primary);
}

Padding _saldoCard(ColorScheme colorScheme, double saldo, Color color) {
  return Padding(
    padding: const EdgeInsets.only(right: 0.0, top: 8, bottom: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        // Fondo suave basado en tu color primario
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Icono opcional para dar contexto
          Icon(Icons.account_balance_wallet_outlined, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            "\$${saldo.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}
