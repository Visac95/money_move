import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Alineado con la lista
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Bordes bien redondeados
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(146, 0, 0, 0), // Sombra muy sutil
            blurRadius: 20, // Muy borrosa (efecto nube)
            offset: const Offset(0, 8), // Cae hacia abajo
          ),
        ],
      ),
      child: Column(
        children: [
          // --- ZONA 1: BALANCE PRINCIPAL ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: [
                const Text(
                  "Balance total",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    letterSpacing: 0.5, // Un poco de aire entre letras
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "\$${provider.saldoActual.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 40, // Mucho más grande = Héroe de la pantalla
                    fontWeight: FontWeight.w800, // Extra negrita
                    color: Colors.black87,
                    letterSpacing: -1.0, // Las fuentes grandes se ven mejor pegaditas
                  ),
                ),
              ],
            ),
          ),

          // --- ZONA 2: RESUMEN INGRESOS/GASTOS (PIE DE PÁGINA) ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              // Un color de fondo muy suave para separar esta sección
              color: const Color(0xFFF9FAFB), 
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey.shade100), // Línea sutil arriba
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribución perfecta
              children: [
                // BLOQUE INGRESOS
                _buildSummaryColumn(
                  label: "Ingresos",
                  amount: provider.totalIngresos,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.incomeColor,
                  bgColor: const Color.fromARGB(48, 16, 185, 129), // Fondo del ícono
                ),

                // LÍNEA DIVISORIA VERTICAL
                Container(height: 30, width: 1, color: Colors.grey.shade300),

                // BLOQUE GASTOS
                _buildSummaryColumn(
                  label: "Gastos",
                  amount: provider.totalEgresos,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.expenseColor,
                  bgColor: const Color.fromARGB(40, 239, 68, 68), // Fondo del ícono
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER PARA NO REPETIR CÓDIGO ---
  // Esto hace el código más limpio y fácil de mantener
  Widget _buildSummaryColumn({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Row(
      children: [
        // Ícono circular
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "\$${amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}