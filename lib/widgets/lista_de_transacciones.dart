import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/screens/edit_transaction_screen.dart';
import 'package:money_move/screens/ver_transaction.dart';
import 'package:provider/provider.dart';

class ListaDeTransacciones extends StatefulWidget {
  const ListaDeTransacciones({super.key});

  @override
  State<ListaDeTransacciones> createState() => _ListaDeTransaccionesState();
}

class _ListaDeTransaccionesState extends State<ListaDeTransacciones> {
  // FUNCIÓN ACTUALIZADA: Solo fecha
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

    return Expanded(
      child: lista.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 60,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No hay transacciones aún",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
              itemCount: lista.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final transaction = lista[index];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(16, 0, 0, 0),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: GestureDetector(
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
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),

                      // A. ÍCONO
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          AppConstants.getIconForCategory(
                            transaction.categoria,
                          ),
                          color: Colors.black87,
                          size: 24,
                        ),
                      ),

                      // B. TÍTULO
                      title: Text(
                        transaction.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),

                      // C. SUBTÍTULO (MONTO + FECHA)
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: [
                            // 1. El Monto
                            Text(
                              (transaction.isExpense ? '-' : '+') +
                                  transaction.monto.toStringAsFixed(2),
                              style: TextStyle(
                                color: transaction.isExpense
                                    ? AppColors.expenseColor
                                    : AppColors.incomeColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),

                            // 2. Separador
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Icon(
                                Icons.circle,
                                size: 4,
                                color: Colors.grey.shade300,
                              ),
                            ),

                            // 3. La Fecha (Solo día/mes/año)
                            // CAMBIO: Usamos ícono de calendario
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(transaction.fecha),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // D. MENÚ
                      trailing: PopupMenuButton(
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          color: Colors.grey.shade400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          if (value == "borrar") {
                            Provider.of<TransactionProvider>(
                              context,
                              listen: false,
                            ).deleteTransaction(transaction.id);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transacción eliminada'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                          if (value == "editar") {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditTransactionScreen(
                                  transaction: transaction,
                                ),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: "borrar",
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Borrar",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: "editar",
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_rounded,
                                  color: AppColors.incomeColor,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Editar",
                                  style: TextStyle(
                                    color: AppColors.incomeColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
