import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/utils/category_translater.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class BalanceCard extends StatelessWidget {
  double totalAmount;
  double incomeAmount;
  double expenseAmount;
  bool withFilterButton = false;

  BalanceCard({
    super.key,
    required this.totalAmount,
    required this.incomeAmount,
    required this.expenseAmount,
    required this.withFilterButton,
  });

  @override
  Widget build(BuildContext context) {
    // Acceso al tema
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final strings = AppLocalizations.of(context)!;
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        // FONDO: Blanco en día, Gris Oscuro en noche
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        // SOMBRA: Solo la mostramos en modo claro (isDark == false)
        // En modo oscuro, las sombras ensucian la interfaz.
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.1,
                  ), // Bajé un poco la opacidad para que sea más elegante
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
        // Opcional: Un borde muy fino en modo oscuro para definir la tarjeta
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.1))
            : null,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 130, // Le damos una altura fija o mínima para que respire
            width: double.infinity, // OBLIGAMOS al Stack a usar todo el ancho
            child: Stack(
              alignment: Alignment.center,
              children: [
                // A. EL BALANCE (Centrado)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      strings.totalBalanceText,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "\$${totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ],
                ),

                // B. EL BOTÓN (En la esquina)
                withFilterButton
                    ? Positioned(
                        top: 10,
                        right: 10,
                        child: PopupMenuButton(
                          // Le quitamos el padding por defecto para que no ocupe espacio extra invisible
                          padding: EdgeInsets.zero,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              colorScheme.primary,
                            ),
                            // Hacemos el botón un poco más pequeño y redondeado
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Hice el icono y texto un poco más pequeños para que encajen bien en la esquina
                                Icon(
                                  AppConstants.getIconForCategory(
                                    provider.catFiltroActual,
                                  ),
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  getCategoryName(
                                    context,
                                    provider.catFiltroActual,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                          onSelected: (value) {
                            provider.cambiarCatFiltro(value);
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                                _popupMenuItem(context, "all"),
                                _popupMenuItem(context, "cat_food"),
                                _popupMenuItem(context, "cat_transport"),
                                _popupMenuItem(context, "cat_leisure"),
                                _popupMenuItem(context, "cat_health"),
                                _popupMenuItem(context, "cat_education"),
                                _popupMenuItem(context, "cat_church"),
                                _popupMenuItem(context, "cat_job"),
                                _popupMenuItem(context, "cat_pet"),
                                _popupMenuItem(context, "cat_home"),
                                _popupMenuItem(context, "cat_services"),
                                _popupMenuItem(context, "cat_debt"),
                                _popupMenuItem(context, "cat_others"),
                              ],
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),

          // --- ZONA 2: RESUMEN INGRESOS/GASTOS (PIE DE PÁGINA) ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: isDark
                    ? [colorScheme.surface, colorScheme.surfaceContainer]
                    : [
                        Colors.white,
                        colorScheme.surfaceContainer.withValues(alpha: 0.5),
                      ],
              ),

              borderRadius: BorderRadius.circular(24),

              // Mantenemos tus sombras originales (estaban perfectas)
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
              // Mantenemos el borde fino para el modo oscuro
              border: isDark
                  ? Border.all(color: Colors.white.withValues(alpha: 0.1))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // BLOQUE INGRESOS
                _buildSummaryColumn(
                  context, // Pasamos el contexto para los estilos
                  label: strings.incomesText,
                  amount: incomeAmount,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.income, // Mantenemos el verde semántico
                  bgColor: AppColors.income.withValues(alpha: 0.15),
                ),

                // LÍNEA DIVISORIA VERTICAL
                Container(
                  height: 30,
                  width: 1,
                  color: colorScheme.outlineVariant, // Gris suave adaptable
                ),

                // BLOQUE GASTOS
                _buildSummaryColumn(
                  context,
                  label: strings.expencesText,
                  amount: expenseAmount,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.expense, // Mantenemos el rojo semántico
                  bgColor: AppColors.expense.withValues(alpha: 0.15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _popupMenuItem(BuildContext context, String caregory) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return PopupMenuItem<String>(
      value: caregory,
      child: Row(
        children: [
          Icon(
            AppConstants.getIconForCategory(caregory),
            color: colorScheme.primary,
          ),
          SizedBox(width: 10),
          Text(
            getCategoryName(context, caregory),
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
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
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
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
