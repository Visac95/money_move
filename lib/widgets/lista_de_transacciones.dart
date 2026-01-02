import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/screens/edit_transaction_screen.dart';
import 'package:money_move/screens/ver_transaction.dart';
import 'package:money_move/utils/date_formater.dart';
import 'package:money_move/utils/ui_utils.dart';
import 'package:provider/provider.dart';

class ListaDeTransacciones extends StatelessWidget {
  const ListaDeTransacciones({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final lista = provider.transactions;
    
    // Accedemos al tema
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: lista.isEmpty
          ? _buildEmptyState(context, colorScheme)
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
              itemCount: lista.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final transaction = lista[index];
                return _TransactionCard(transaction: transaction);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // Usamos un color de contenedor suave del tema
              color: colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 50,
              // El icono usa el color primario o variante
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.noTransactionsYet,
            style: TextStyle(
              color: colorScheme.onSurface, // Texto principal
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            AppLocalizations.of(context)!.transactionsWillAppearHereText,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant, // Texto secundario
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget separado para mantener el código limpio
class _TransactionCard extends StatelessWidget {
  final dynamic transaction; // Usa tu modelo Transaction aquí

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bool isExpense = transaction.isExpense;
    final Color amountColor = isExpense ? AppColors.expense : AppColors.income;

    return Container(
      decoration: BoxDecoration(
        // Fondo adaptable: blanco en light, gris oscuro en dark
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        // Sombra solo en modo claro. En modo oscuro se ve mal.
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VerTransaction(
                id: transaction.id,
                title: transaction.title,
                description: transaction.description,
                monto: transaction.monto,
                fecha: transaction.fecha,
                categoria: transaction.categoria,
                isExpense: transaction.isExpense,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // 1. ICONO (Cuadrado redondeado suave)
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    // Fondo del icono basado en el color primario del tema
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    AppConstants.getIconForCategory(transaction.categoria),
                    // Color del icono que contrasta con el primaryContainer
                    color: colorScheme.onPrimaryContainer,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 16),

                // 2. TÍTULO Y FECHA
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: colorScheme.onSurface, // Color adaptable
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: colorScheme
                                .onSurfaceVariant, // Color gris suave
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatDate(transaction.fecha),
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. MONTO Y MENÚ
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (isExpense ? '- ' : '+ ') +
                          transaction.monto.toStringAsFixed(2),
                      style: TextStyle(
                        color: amountColor, // Rojo o Verde (se mantiene igual)
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Menú de 3 puntos
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: _buildPopupMenu(context, colorScheme),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, ColorScheme colorScheme) {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      color: colorScheme.surfaceContainer, // Fondo del menú desplegable
      icon: Icon(
        Icons.more_horiz,
        size: 20,
        color: colorScheme.onSurfaceVariant, // Icono de 3 puntos adaptable
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (value) {
        if (value == "borrar") {
          UiUtils.showDeleteConfirmation(context, () {
            // Esto solo se ejecuta si el usuario dice "SÍ"
            Provider.of<TransactionProvider>(
              context,
              listen: false,
            ).deleteTransaction(transaction.id);
          });
        }
        if (value == "editar") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  EditTransactionScreen(transaction: transaction),
            ),
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: "editar",
          child: Row(
            children: [
              Icon(Icons.edit_rounded, color: AppColors.income),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.editText,
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: "borrar",
          child: Row(
            children: [
              const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.deleteText,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
