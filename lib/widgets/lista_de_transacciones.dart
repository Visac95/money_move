import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/l10n/app_localizations.dart';
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
    final provider = Provider.of<TransactionProvider>(context);
    final lista = provider.transactions;
    final colorScheme = Theme.of(context).colorScheme;

    if (lista.isEmpty) {
      return SizedBox(
        height: 300, // Altura mínima para que se vea el mensaje
        child: _buildEmptyState(context, colorScheme),
      );
    }

    // --- CORRECCIÓN PRINCIPAL ---
    // Quitamos el 'Expanded' que suele romper la pantalla si hay ScrollView padre.
    return ListView.separated(
      // shrinkWrap: true hace que la lista ocupe solo lo que necesitan sus items
      shrinkWrap: true,
      // NeverScrollableScrollPhysics hace que esta lista no tenga su propio scroll,
      // sino que se mueva con la pantalla principal.
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
      itemCount: lista.length,
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        final transaction = lista[index];
        return _TransactionCard(transaction: transaction);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    // (Tu código del EmptyState estaba perfecto, lo dejo igual pero resumido aquí)
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
            AppLocalizations.of(context)?.noTransactionsYet ??
                "No transactions",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            AppLocalizations.of(context)?.transactionsWillAppearHereText ??
                "...",
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final dynamic transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // --- PROTECCIÓN CONTRA NULOS ---
    // Si por error algo viene nulo, usamos valores por defecto para que NO explote la app
    final bool isExpense = transaction.isExpense ?? true;
    final Color amountColor = isExpense ? AppColors.expense : AppColors.income;
    final double amount = transaction.monto ?? 0.0;
    final String title = transaction.title ?? "Sin título";
    final String category = transaction.categoria ?? "cat_other";

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
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
                description: transaction.description ?? "",
                monto: amount,
                fecha: transaction.fecha ?? DateTime.now(),
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
                    // Usamos la variable 'category' segura que definimos arriba
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
                            formatDate(transaction.fecha ?? DateTime.now()),
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

                // 3. MONTO
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (isExpense ? '- ' : '+ ') + amount.toStringAsFixed(2),
                      style: TextStyle(
                        color: amountColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
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
    // (Tu código del menú estaba bien, solo asegúrate de pasar 'transaction' correctamente)
    // ... Copia tu menú anterior aquí ...
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
