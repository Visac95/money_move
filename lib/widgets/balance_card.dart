import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    
    // Acceso al tema
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        // FONDO: Blanco en día, Gris Oscuro en noche
        color: colorScheme.surface, 
        borderRadius: BorderRadius.circular(24),
        // SOMBRA: Solo la mostramos en modo claro (isDark == false)
        // En modo oscuro, las sombras ensucian la interfaz.
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Bajé un poco la opacidad para que sea más elegante
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        // Opcional: Un borde muy fino en modo oscuro para definir la tarjeta
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
      ),
      child: Column(
        children: [
          // --- ZONA 1: BALANCE PRINCIPAL ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: [
                Text(
                  "Balance total",
                  style: TextStyle(
                    // Color secundario (grisáceo adaptable)
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "\$${provider.saldoActual.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    // Color principal (Negro en día / Blanco en noche)
                    color: colorScheme.onSurface, 
                    letterSpacing: -1.0,
                  ),
                ),
              ],
            ),
          ),

          // --- ZONA 2: RESUMEN INGRESOS/GASTOS (PIE DE PÁGINA) ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              // FONDO FOOTER: Usamos un tono ligeramente distinto al fondo principal
              // surfaceContainer suele ser un poco más gris/oscuro que surface
              color: colorScheme.surfaceContainer, 
              
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border(
                // Borde superior sutil adaptable
                top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4)), 
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // BLOQUE INGRESOS
                _buildSummaryColumn(
                  context, // Pasamos el contexto para los estilos
                  label: "Ingresos",
                  amount: provider.totalIngresos,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.income, // Mantenemos el verde semántico
                  bgColor: AppColors.income.withOpacity(0.15),
                ),

                // LÍNEA DIVISORIA VERTICAL
                Container(
                  height: 30, 
                  width: 1, 
                  color: colorScheme.outlineVariant // Gris suave adaptable
                ),

                // BLOQUE GASTOS
                _buildSummaryColumn(
                  context,
                  label: "Gastos",
                  amount: provider.totalEgresos,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.expense, // Mantenemos el rojo semántico
                  bgColor: AppColors.expense.withOpacity(0.15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(
    BuildContext context, {
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    // Obtenemos colores locales
    final colorScheme = Theme.of(context).colorScheme;

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
                // Texto secundario adaptable
                color: colorScheme.onSurfaceVariant, 
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "\$${amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                // Aquí podrías usar 'color' (verde/rojo) o colorScheme.onSurface
                // Lo dejaré con 'color' porque suele gustar que se vea verde/rojo también el número
                color: color, 
              ),
            ),
          ],
        ),
      ],
    );
  }
}