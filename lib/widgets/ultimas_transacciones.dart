import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(32, 0, 0, 0),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          lista.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("No hay transacciones aún 😴",
                      style: TextStyle(color: Colors.grey)), // Usamos grey si textLight no está definido
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lista.length > 3 ? 3 : lista.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final transaction = lista[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      
                      // 1. ÍCONO
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          AppConstants.getIconForCategory(transaction.categoria),
                          color: AppColors.primaryDark,
                          size: 22,
                        ),
                      ),

                      // 2. TÍTULO
                      title: Text(
                        transaction.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
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
                                fontWeight: FontWeight.w600,
                                color: transaction.isExpense
                                    ? AppColors.expenseColor
                                    : AppColors.incomeColor,
                                fontSize: 14,
                              ),
                            ),

                            // B. Separador (Puntito)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Icon(Icons.circle, size: 4, color: Colors.grey.shade300),
                            ),

                            // C. La Fecha
                            Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(transaction.fecha),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12, // Un pelín más pequeña para que quepa bien
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

          const SizedBox(height: 16),

          // 4. BOTÓN VER TODAS
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () =>
                  Provider.of<UiProvider>(context, listen: false).selectedIndex = 1,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Ver todas las transacciones",
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