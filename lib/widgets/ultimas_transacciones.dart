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
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final lista = provider.transactions;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Un poco más de margen lateral
      padding: const EdgeInsets.all(16), // Padding interno para que el contenido no pegue con los bordes
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Bordes más redondeados (moderno)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Sombra MUY suave (5% opacidad)
            blurRadius: 15, // Muy difusa
            offset: const Offset(0, 5), // Ligeramente hacia abajo
          ),
        ],
      ),
      child: Column(
        children: [
          // Header opcional si quisieras poner título
          // Align(alignment: Alignment.centerLeft, child: Text("Recientes", style: ...)),
          // SizedBox(height: 10),

          lista.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("No hay transacciones aún 😴", style: TextStyle(color: Colors.grey)),
                )
              : ListView.separated( // Usamos separated para dar aire entre items
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Importante para que no haga scroll dentro del scroll
                  itemCount: lista.length > 3 ? 3 : lista.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8), // Espacio entre filas
                  itemBuilder: (context, index) {
                    final transaction = lista[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero, // Quitamos padding default para alinearlo nosotros
                      
                      // 1. ÍCONO MEJORADO (Tipo App Bancaria)
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100, // Fondo gris muy clarito
                          borderRadius: BorderRadius.circular(12), // Cuadrado redondeado (Squircle)
                        ),
                        child: Icon(
                          AppConstants.getIconForCategory(transaction.categoria),
                          color: Colors.black87, // Ícono oscuro para contraste
                          size: 22,
                        ),
                      ),
                      
                      // 2. TÍTULO Y MONTO
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
                      
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0), // Separación título-monto
                        child: Text(
                          (transaction.isExpense ? '-' : '+') +
                              transaction.monto.toStringAsFixed(2),
                          style: TextStyle(
                            fontWeight: FontWeight.w600, // Semi-bold
                            color: transaction.isExpense
                                ? AppColors.expenseColor // Rojo
                                : AppColors.incomeColor, // Verde
                            fontSize: 14,
                          ),
                        ),
                      ),
                      
                      // 3. MENÚ DE PUNTOS (Más sutil)
                      trailing: PopupMenuButton(
                        icon: Icon(Icons.more_vert, color: Colors.grey.shade400), // Ícono gris suave
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (value) {
                           if (value == "borrar") {
                            Provider.of<TransactionProvider>(context, listen: false)
                                .deleteTransaction(transaction.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Transacción eliminada')),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: "borrar",
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red, size: 20),
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

          const SizedBox(height: 16), // Espacio antes del botón

          // 4. BOTÓN ESTILO "SOFT" (Como en tu imagen)
          SizedBox(
            width: double.infinity,
            child: TextButton( // Usamos TextButton o ElevatedButton con estilo plano
              onPressed: () =>
                  Provider.of<UiProvider>(context, listen: false).selectedIndex = 1,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF3E5F5), // Un lila muy suave (casi blanco)
                foregroundColor: Colors.purple, // Color del texto/ícono
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Bordes totalmente redondos (Pill shape)
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