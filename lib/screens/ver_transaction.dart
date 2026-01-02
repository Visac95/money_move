import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/screens/edit_transaction_screen.dart';
import 'package:money_move/l10n/app_localizations.dart'; // Asegúrate que esta ruta esté bien
import 'package:money_move/utils/category_translater.dart';
import 'package:money_move/utils/ui_utils.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';

class VerTransaction extends StatelessWidget {
  final String id;
  // Mantenemos los parámetros por compatibilidad, aunque lo ideal es usar solo el ID
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
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return "$day/$month/$year";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    Transaction? transaction = provider.getTransactionById(id);

    // Acceso rápido al tema actual (Esto es lo que hace funcionar el modo oscuro)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (transaction == null) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context)!.transactionNotExist),
        ),
      );
    }

    // Colores financieros (Rojo/Verde) se mantienen igual en ambos modos
    final Color mainColor = transaction.isExpense
        ? AppColors.expense
        : AppColors.income;

    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // El color de fondo ahora lo decide el main.dart automáticamente
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.transactionDetailsTitle,
          style: TextStyle(color: colorScheme.onSurface), // Texto se adapta
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          // El icono será negro en día, blanco en noche
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // 1. EL HÉROE (El Monto)
              Hero(
                tag: transaction.id,
                child: Text(
                  "${transaction.isExpense ? '- ' : '+ '}\$${transaction.monto.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: mainColor, // Mantenemos rojo/verde
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
              Text(
                transaction.isExpense
                    ? AppLocalizations.of(context)!.expenseMade
                    : AppLocalizations.of(context)!.incomeReceived,
                style: TextStyle(
                  // Usamos 'outline' (nuestro gris secundario definido en main)
                  color: colorScheme.outline,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              // 2. LA TARJETA DE DETALLES
              _cardConteiner(
                colorScheme,
                isDark,
                mainColor,
                transaction,
                context,
              ),

              const SizedBox(height: 40), 

              // 3. BOTONES DE ACCIÓN
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          EditTransactionScreen(transaction: transaction),
                    ),
                  ),
                  icon: Icon(Icons.edit_rounded, color: colorScheme.surface),
                  label: Text(
                    AppLocalizations.of(context)!.editTransaccionText,
                    style: TextStyle(color: colorScheme.surface, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    // Usamos el color Primario del tema (Tu Indigo)
                    backgroundColor: colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Botón ELIMINAR
              SizedBox(
                width: double.infinity,
                height: 55,
                child: TextButton.icon(
                  onPressed: () {
                    UiUtils.showDeleteConfirmation(context, () {
                      // Esto solo se ejecuta si el usuario dice "SÍ"
                      Provider.of<TransactionProvider>(
                        context,
                        listen: false,
                      ).deleteTransaction(transaction.id);
                      Navigator.pop(context);
                    });
                  },
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  label: Text(
                    AppLocalizations.of(context)!.deleteTransactionText,
                    style: TextStyle(color: colorScheme.error, fontSize: 16),
                  ),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Container _cardConteiner(
    ColorScheme colorScheme,
    bool isDark,
    Color mainColor,
    Transaction transaction,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        // Aquí la magia: surface es Blanco(Día) o Gris Oscuro(Noche)
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: colorScheme.onSurface, // Sombra sutil
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
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
                    AppLocalizations.of(context)!.category,
                    style: TextStyle(
                      color: colorScheme.outline, // Gris adaptable
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    getCategoryName(context, transaction.categoria),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface, // Negro/Blanco
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // Título y Descripción
          _buildDetailRow(
            context, // Pasamos el contexto para leer colores
            AppLocalizations.of(context)!.titleText,
            transaction.title,
          ),
          const SizedBox(height: 15),
          _buildDetailRow(
            context,
            AppLocalizations.of(context)!.dateText,
            _formatDate(transaction.fecha),
          ),
          const SizedBox(height: 15),

          // Descripción
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.descriptionText,
                  style: TextStyle(color: colorScheme.outline, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  transaction.description.isEmpty
                      ? AppLocalizations.of(context)!.noDescription
                      : transaction.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface, // Negro/Blanco
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar actualizado
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: theme.colorScheme.outline, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
