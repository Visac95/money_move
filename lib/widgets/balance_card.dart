import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    return Card(
      margin: const EdgeInsets.all(22),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          const Text("Balance total", style: TextStyle(color: Colors.grey)),
          Text(
            "\$${provider.saldoActual.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: AppColors.incomeColor,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text('Ingresos', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${provider.totalIngresos.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.incomeColor,
                    ),
                  ),
                ],
              ),

              // COLUMNA ROJA (GASTOS)
              Column(
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: AppColors.expenseColor,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text('Gastos', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${provider.totalEgresos.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.expenseColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
