import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class ListaDeTransacciones extends StatefulWidget {
  const ListaDeTransacciones({super.key});

  @override
  State<ListaDeTransacciones> createState() => _ListaDeTransaccionesState();
}

class _ListaDeTransaccionesState extends State<ListaDeTransacciones> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final lista = provider.transactions;

    return Expanded(
      child: lista.isEmpty
          // 1. ESTADO VACÍO MEJORADO
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    "No hay transacciones aún",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          // 2. LISTA CON SEPARACIÓN Y PADDING
          : ListView.separated(
              physics: const BouncingScrollPhysics(), // Rebote suave tipo iOS
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 80), // Padding inferior de 80 para el botón flotante
              itemCount: lista.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12), // Espacio entre tarjetas
              itemBuilder: (context, index) {
                final transaction = lista[index];
                
                // 3. TARJETA INDIVIDUAL FLOTANTE
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20), // Bordes muy redondeados
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03), // Sombra casi invisible
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    
                    // A. ÍCONO CON FONDO
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA), // Gris azulado muy suave
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        AppConstants.getIconForCategory(transaction.categoria),
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

                    // C. MONTO (SUBTÍTULO)
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        (transaction.isExpense ? '-' : '+') +
                            transaction.monto.toStringAsFixed(2),
                        style: TextStyle(
                          color: transaction.isExpense
                              ? AppColors.expenseColor
                              : AppColors.incomeColor,
                          fontWeight: FontWeight.w700, // Letra gruesa para el dinero
                          fontSize: 15,
                        ),
                      ),
                    ),

                    // D. MENÚ DE OPCIONES
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.more_horiz_rounded, color: Colors.grey.shade400), // 3 puntos horizontales se ven más modernos
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == "borrar") {
                          Provider.of<TransactionProvider>(
                            context,
                            listen: false,
                          ).deleteTransaction(transaction.id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transacción eliminada'),
                              behavior: SnackBarBehavior.floating, // Flota sobre el contenido
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "borrar",
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                              SizedBox(width: 10),
                              Text(
                                "Borrar",
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}