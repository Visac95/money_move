import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/providers/ui_provider.dart';
import 'package:provider/provider.dart';

class UltimasTransacciones extends StatefulWidget {
  const UltimasTransacciones({super.key});

  @override
  State<UltimasTransacciones> createState() => _UltimasTransaccionesState();
}

class _UltimasTransaccionesState extends State<UltimasTransacciones> {
  // Función auxiliar para la fecha (Día/Mes/Año)
  String _formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return "$day/$month/$year";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final lista = provider.transactions;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final strings = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Fondo adaptable: blanco en light, gris oscuro en dark
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        // Sombra solo en modo claro
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha:0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        children: [
          // Opción 1: Título a la izquierda con ícono de historial
          Padding(
            padding: const EdgeInsets.only(
              bottom: 1,
            ), // Espacio abajo del título
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Separa texto e icono
              children: [
                Text(
                  strings.lastTransactionsText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold, // Negrita para jerarquía
                    color: colorScheme
                        .onSurface, // Color principal (no gris claro)
                  ),
                ),
                Icon(
                  Icons.history_rounded,
                  color: colorScheme.outline, // Icono sutil
                  size: 20,
                ),
              ],
            ),
          ),

          lista.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 40,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.noTransactionsYet,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lista.length > 2 ? 2 : lista.length,
                  // Divider sutil en lugar de espacio vacío
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.transparent,
                  ),
                  itemBuilder: (context, index) {
                    final transaction = lista[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,

                      // 1. ÍCONO DE CATEGORÍA
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // Fondo del icono adaptable al color primario del tema
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          AppConstants.getIconForCategory(
                            transaction.categoria,
                          ),
                          // Color del icono que contrasta con el fondo
                          color: colorScheme.onPrimaryContainer,
                          size: 22,
                        ),
                      ),

                      // 2. TÍTULO
                      title: Text(
                        transaction.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          // Texto principal adaptable (negro/blanco)
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // 3. SUBTÍTULO (MONTO + FECHA)
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            // A. El Monto
                            Text(
                              (transaction.isExpense ? '-' : '+') +
                                  transaction.monto.toStringAsFixed(2),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                // Colores semánticos (Rojo/Verde)
                                color: transaction.isExpense
                                    ? AppColors.expense
                                    : AppColors.income,
                                fontSize: 14,
                              ),
                            ),

                            // B. Separador (Puntito)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                              ),
                              child: Icon(
                                Icons.circle,
                                size: 4,
                                // Color gris suave adaptable
                                color: colorScheme.outline,
                              ),
                            ),

                            // C. La Fecha
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(transaction.fecha),
                              style: TextStyle(
                                // Texto secundario
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

          const SizedBox(height: 1),

          // 4. BOTÓN VER TODAS
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Provider.of<UiProvider>(
                context,
                listen: false,
              ).selectedIndex = 1,
              style: TextButton.styleFrom(
                // Fondo tonal (se ve bien en ambos modos)
                backgroundColor: colorScheme.secondaryContainer.withValues(alpha:
                  0.4,
                ),
                // Texto color primario
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.seeAllTransactionsText,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
