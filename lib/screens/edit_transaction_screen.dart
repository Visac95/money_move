import 'package:flutter/material.dart';
// import 'package:money_move/config/app_colors.dart'; // Ya no se necesita aquí
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/widgets/transaction_form.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;
  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  var titleController = TextEditingController();
  var amountController = TextEditingController();
  var descriptionController = TextEditingController();

  late bool isExpense;
  Timer? debounce;
  String? manualCategory;

  @override
  void initState() {
    super.initState();
    // Carga de datos iniciales
    isExpense = widget.transaction.isExpense;
    titleController.text = widget.transaction.title;
    amountController.text = widget.transaction.monto.toStringAsFixed(2);
    descriptionController.text = widget.transaction.description;
  }

  @override
  void dispose() {
    debounce?.cancel();
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    // --- VALIDACIONES ---
    if (titleController.text.isEmpty || amountController.text.isEmpty) return;

    double enteredAmount;
    try {
      enteredAmount = double.parse(amountController.text);
    } catch (e) {
      return;
    }
    
    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);

    // 2. OBTENEMOS LA CATEGORÍA SUGERIDA O MANUAL
    String categoryToSave = aiProvider.suggestedCategory;
    String? manualCategoryFromProvider = aiProvider.manualCategory;

    // Lógica de decisión:
    if (manualCategoryFromProvider != null) {
      categoryToSave = manualCategoryFromProvider;
    } else if (categoryToSave.isEmpty || categoryToSave == 'manual_category') {
      
      if (!mounted) return; // Seguridad de contexto

      final String? selectedManualCategory = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return const SelectCategoryWindow();
        },
      );

      if (selectedManualCategory != null) {
        categoryToSave = selectedManualCategory;
      } else {
        return; // Canceló
      }
    }
    
    final Transaction transactionActualizada = widget.transaction.update(
      title: titleController.text,
      monto: enteredAmount,
      description: descriptionController.text,
      categoria: manualCategoryFromProvider ?? categoryToSave,
      isExpense: isExpense,
    );
    
    if (!mounted) return;
    context.read<TransactionProvider>().updateTransaction(transactionActualizada);
    
    Navigator.of(context).pop();

    // Reseteamos el provider
    aiProvider.resetCategory();
  }

  @override
  Widget build(BuildContext context) {
    // Acceso al esquema de colores actual
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // backgroundColor: AppColors.white, // ELIMINADO: Ahora es automático
      
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.editTransaccionText,
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            // Color de texto adaptable (Negro día / Blanco noche)
            color: colorScheme.onSurface 
          ),
        ),
        backgroundColor: Colors.transparent, // O colorScheme.surface
        elevation: 0,
        // Icono de "atrás" adaptable
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      
      body: TransactionForm(
        titleController: titleController,
        amountController: amountController,
        descriptionController: descriptionController,
        isExpense: isExpense,
        onTypeChanged: (bool value) {
          setState(() {
            isExpense = value;
          });
        },
        onSave: _saveTransaction,
        transaction: widget.transaction,
        isEditMode: true,
      ),
    );
  }
}