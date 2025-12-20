import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/screens/edit_transaction_screen.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';

class VerTransaction extends StatelessWidget {
  final String id;

  String _formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();

    return "$day/$month/$year";
  }

  const VerTransaction({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.monto,
    required this.fecha,
    required this.categoria,
    required this.isExpense,
  });

  final String title;
  final String description;
  final double monto;
  final DateTime fecha;
  final String categoria;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    Transaction transaction = provider.getTransactionById(id)!;

    return Scaffold(
      appBar: AppBar(title: Text("Detalles de la Transación")),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              color: AppColors.scaffoldBackground,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(_formatDate(transaction.fecha)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            AppConstants.getIconForCategory(
                              transaction.categoria,
                            ),
                            size: 30,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            transaction.title,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 1,
                      width: 1000,
                      color: const Color.fromARGB(255, 223, 225, 231),
                      margin: EdgeInsets.all(3),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Descripción: ${transaction.description}",
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),

            //---------MONTO--------------------
            Text(
              "Monto:",
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(1, 0, 1, 10),
              child: Text(
                (transaction.isExpense ? '-' : '+') +
                    transaction.monto.toStringAsFixed(2) +
                    (transaction.isExpense ? " (Gasto)" : " (Ingreso)"),
                style: TextStyle(
                  color: transaction.isExpense
                      ? AppColors.expenseColor
                      : AppColors.incomeColor,
                  fontSize: 40, // Mucho más grande = Héroe de la pantalla
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0, // Un poco de aire entre letras
                ),
              ),
            ),

            SizedBox(height: 10),

            //------------Categoria-----------
            Text(
              "Categorìa:",
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              transaction.categoria,
              style: TextStyle(
                fontSize: 30,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),

            //--------EDITAR TRANSACCION----------
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 5,
                fixedSize: Size(500, 50),
                backgroundColor: AppColors.incomeColor,
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EditTransactionScreen(transaction: transaction),
                ),
              ),
              child: Text(
                "Editar Transacción",
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),

            //----------ELIMINAR TRANSACCION---------
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 5,
                fixedSize: Size(500, 50),
                backgroundColor: AppColors.expenseColor,
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EditTransactionScreen(transaction: transaction),
                ),
              ),
              child: Text(
                "Eliminar Transacción",
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
