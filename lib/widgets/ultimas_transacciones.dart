import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class UltimasTransacciones extends StatefulWidget {
  const UltimasTransacciones({super.key});

  @override
  State<UltimasTransacciones> createState() => _UltimasTransaccionesState();
}

class _UltimasTransaccionesState extends State<UltimasTransacciones> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final lista = provider.transactions;
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(67, 0, 0, 0),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          // Text(
          //   "Últimas Transacciones",
          //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold ),
          // ),
          lista.isEmpty
              ? Center(child: Text("No hay transacciones aun"))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: lista.length > 3 ? 3 : lista.length,
                  itemBuilder: (context, index) {
                    final transaction = lista[index];
                    return ListTile(
                      title: Text(
                        transaction.title,
                        style: TextStyle(
                          color: transaction.isExpense
                              ? AppColors.expenseColor
                              : AppColors.incomeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        (transaction.isExpense ? '-' : '+') +
                            transaction.monto.toStringAsFixed(2),
                        style: TextStyle(
                          // Aplicamos el color también al subtítulo (el monto)
                          color: transaction.isExpense
                              ? AppColors.expenseColor
                              : AppColors.incomeColor,
                        ),
                      ),
                      leading: Icon(
                        AppConstants.getIconForCategory(transaction.categoria),
                        color: AppColors.transactionListIconColor,
                      ),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == "borrar") {
                            Provider.of<TransactionProvider>(
                              context,
                              listen: false,
                            ).deleteTransaction(transaction.id);

                            // Opcional: Mostrar confirmación
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transacción eliminada'),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: "borrar",
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  "Borrar",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ElevatedButton(style: ButtonStyle(
            maximumSize: WidgetStateProperty.all(Size(double.infinity, 40))
          ),
            onPressed: () => 1 + 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_forward),
                Text("Ver todas las transacciones"),
              ],
            ),
          ),
        ],
      ),
    );
    ;
  }
}
