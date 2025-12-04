import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/screens/add_transaction_screen.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final lista = provider.transactions;
    return Scaffold(
      appBar: AppBar(title: Text("MoneyMove")),
      body: lista.isEmpty
          ? Center(child: Text("No hay transacciones aun"))
          : ListView.builder(
              itemCount: lista.length,
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
                    color: Colors.blue,
                  ),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == "borrar") {
                        Provider.of<TransactionProvider>(
                          context,
                          listen: false,
                        ).deleteTrasnsaction(transaction.id);

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
                            Text("Borrar", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
