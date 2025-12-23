import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/screens/edit_transaction_screen.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';

class VerTransaction extends StatelessWidget {
  final String id;
  // Estos parámetros ya no son estrictamente necesarios si los sacas del provider,
  // pero los dejaré por compatibilidad con tu código actual.
  final String title;
  final String description;
  final double monto;
  final DateTime fecha;
  final String categoria;
  final bool isExpense;

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

  String _formatDate(DateTime date) {
    // Tip Pro: Podrías usar el paquete 'intl' para esto: DateFormat.yMMMd().format(date)
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return "$day/$month/$year";
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos la transacción actualizada del provider
    final provider = Provider.of<TransactionProvider>(context);
    
    // Manejo de seguridad por si se borró y la pantalla sigue abierta
    Transaction? transaction = provider.getTransactionById(id);
    
    if (transaction == null) {
      return Scaffold(body: Center(child: Text("La transacción no existe")));
    }

    // Definimos el color principal según si es gasto o ingreso
    final Color mainColor = transaction.isExpense 
        ? AppColors.expenseColor 
        : AppColors.incomeColor;

    return Scaffold(
      backgroundColor: AppColors.primaryLight, // Asegúrate de tener un color de fondo suave
      appBar: AppBar(
        title: const Text("Detalle de Movimiento"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView( // Para evitar overflow en pantallas pequeñas
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // 1. EL HÉROE (El Monto)
              // Lo ponemos arriba y gigante. Es lo que el usuario quiere ver.
              Hero( // Animación bonita si vienes de la lista
                tag: transaction.id,
                child: Text(
                  (transaction.isExpense ? '- ' : '+ ') +
                      "\$${transaction.monto.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 48, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
              Text(
                transaction.isExpense ? "Gasto Realizado" : "Ingreso Recibido",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              // 2. LA TARJETA DE DETALLES (Estilo "Recibo")
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white, // O AppColors.cardColor
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Icono y Categoría
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            AppConstants.getIconForCategory(transaction.categoria),
                            size: 30,
                            color: mainColor,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Categoría",
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                            Text(
                              transaction.categoria,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    const Divider(), // Usar Widget Divider es mejor que Container width:1000
                    const SizedBox(height: 20),

                    // Título y Descripción
                    _buildDetailRow("Título", transaction.title),
                    const SizedBox(height: 15),
                    _buildDetailRow("Fecha", _formatDate(transaction.fecha)),
                    const SizedBox(height: 15),
                    
                    // Descripción con manejo de texto largo
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Descripción", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          const SizedBox(height: 5),
                          Text(
                            transaction.description.isEmpty 
                                ? "Sin descripción" 
                                : transaction.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 3. BOTONES DE ACCIÓN
              // Botón Principal: EDITAR
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          EditTransactionScreen(transaction: transaction!),
                    ),
                  ),
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  label: const Text("Editar Transacción", style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark, // Usamos el color de marca, no verde
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 15),

              // Botón Secundario: ELIMINAR (Estilo "Peligro" pero sutil)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: TextButton.icon(
                  // AQUÍ CONECTAMOS EL POPUP QUE HICIMOS ANTES
                  onPressed: () {
                     // Aquí iría la lógica del ShowDialog que te expliqué antes
                     // _showDeleteConfirmation(context);
                     print("Lógica de eliminar aquí");
                  }, 
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text("Eliminar Transacción", style: TextStyle(color: Colors.red, fontSize: 16)),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              
              // Espacio extra abajo para que no pegue con el borde en algunos celulares
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para no repetir código en las filas de detalles
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}