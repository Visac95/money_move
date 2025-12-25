import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/screens/edit_transaction_screen.dart';
import 'package:money_move/screens/ver_transaction.dart';
import 'package:provider/provider.dart';

class ListaDeTransacciones extends StatelessWidget {
  const ListaDeTransacciones({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final lista = provider.transactions;

    return Expanded(
      child: lista.isEmpty
          ? _buildEmptyState()
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.textLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 50,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Sin movimientos",
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Tus transacciones aparecerán aquí",
            style: TextStyle(color: AppColors.textLight, fontSize: 14),
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

  String _formatDate(DateTime date) {
    // Formato corto: 24/10
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpense = transaction.isExpense;
    final Color amountColor = isExpense
        ? AppColors.expenseColor
        : AppColors.incomeColor;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24), // Bordes más redondeados
        boxShadow: [
          BoxShadow(
            color: AppColors.textLight, // Sombra muy sutil
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
                    color: AppColors.primaryColor.withOpacity(
                      0.1,
                    ), // Fondo suave
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    AppConstants.getIconForCategory(transaction.categoria),
                    color: AppColors.primaryDark,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.transactionListIconColor, // Color oscuro suave
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
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(transaction.fecha),
                            style: TextStyle(
                              color: AppColors.textLight,
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
                        color: amountColor,
                        fontWeight: FontWeight.w800, // Extra bold para números
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4), // Espacio pequeño
                    // Menú de 3 puntos discreto
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: _buildPopupMenu(context),
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

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.more_horiz,
        size: 20,
        color: AppColors.textDark,
      ), // Icono muy sutil
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (value) {
        if (value == "borrar") {
          Provider.of<TransactionProvider>(
            context,
            listen: false,
          ).deleteTransaction(transaction.id);
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(AppLocalizations.of(context)!.deletedTransactionMessage)),
          );
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
              Icon(Icons.edit_rounded, color: AppColors.incomeColor),
              SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.editText),
            ],
          ),
        ),
         PopupMenuItem(
          value: "borrar",
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.deleteText, style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
    );
  }
}
