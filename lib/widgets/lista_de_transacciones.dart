import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/transaction.dart'; // Asegúrate de importar tu modelo
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/screens/edit_transaction_screen.dart';
import 'package:money_move/screens/ver_transaction_screen.dart';
import 'package:money_move/utils/date_formater.dart';
import 'package:money_move/utils/ui_utils.dart';
import 'package:provider/provider.dart';

class ListaDeTransacciones extends StatelessWidget {
  const ListaDeTransacciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final lista = provider.transacionesParaMostrar;
        final colorScheme = Theme.of(context).colorScheme;

        // A. SI ESTÁ VACÍA
        if (lista.isEmpty) {
          return SizedBox(
            height: 300,
            child: _buildEmptyState(context, colorScheme),
          );
        }
        return ListView.separated(
          // shrinkWrap + physics: Truco para que funcione dentro del Home sin scroll doble
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
          itemCount: lista.length,
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final transaction = lista[index];
            return _TransactionCard(transaction: transaction);
          },
        );
      },
    );

    // 2. LISTA DE DATOS
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 50,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.noTransactionsYet,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            AppLocalizations.of(context)!.transactionsWillAppearHereText,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction; // Usamos el tipo fuerte 'Transaction'

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    // --- VARIABLES SEGURAS ---
    final bool isExpense = transaction.isExpense;
    final Color amountColor = isExpense ? AppColors.expense : AppColors.income;
    final double amount = transaction.monto;
    final String title = transaction.title;
    final String category = transaction.categoria;

    // Calculamos el saldo acumulado (protegido contra errores)
    String saldoText = "---";
    try {
      double saldoCalculado = provider.getSaldoTransaction(transaction);
      saldoText = "\$${saldoCalculado.toStringAsFixed(2)}";
    } catch (e) {
      saldoText = "\$${transaction.saldo.toStringAsFixed(2)}";
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
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
              builder: (context) => VerTransactionScreen(
                id: transaction.id,
                title: title,
                description: transaction.description,
                monto: amount,
                fecha: transaction.fecha,
                categoria: category,
                isExpense: isExpense,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // 1. ICONO
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    AppConstants.getIconForCategory(category),
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
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: colorScheme.onSurface,
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
                            color: colorScheme.onSurfaceVariant,
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

                // 3. MONTO Y SALDO
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (isExpense ? '- ' : '+ ') + amount.toStringAsFixed(2),
                      style: TextStyle(
                        color: amountColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16, // Ajustado un poco para evitar overflow
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      saldoText,
                      style: TextStyle(
                        color: colorScheme.outline,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 5), // Espacio reducido
                // 4. MENÚ
                SizedBox(
                  height: 30, // Un poco más grande para facilitar el toque
                  width: 30,
                  child: _buildPopupMenu(context, colorScheme, transaction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(
    BuildContext context,
    ColorScheme colorScheme,
    Transaction tx,
  ) {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      color: colorScheme.surfaceContainer,
      icon: Icon(
        Icons.more_horiz,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (value) {
        if (value == "borrar") {
          UiUtils.showDeleteConfirmation(context, () {
            Provider.of<TransactionProvider>(
              context,
              listen: false,
            ).deleteTransaction(tx.id);
          });
        }
        if (value == "editar") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditTransactionScreen(transaction: tx),
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
