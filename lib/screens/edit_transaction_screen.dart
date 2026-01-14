import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/widgets/transaction_form.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:provider/provider.dart';

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
  // Eliminado: String? manualCategory; (Usamos el Provider)

  @override
  void initState() {
    super.initState();
    // 1. Carga de datos de texto
    isExpense = widget.transaction.isExpense;
    titleController.text = widget.transaction.title;
    amountController.text = widget.transaction.monto.toStringAsFixed(2);
    descriptionController.text = widget.transaction.description;

    titleController.addListener(_classifyTitle);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);
        aiProvider.manualCategory = widget.transaction.categoria;
      }
    });
  }

  @override
  void dispose() {
    Future.microtask(() {
    });
    debounce?.cancel();
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Lógica IA Idéntica a AddTransaction
  void _classifyTitle() {
    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);

    // Si ya hay una categoría (la original o una nueva manual), la IA no hace nada.
    if (aiProvider.manualCategory != null) return;

    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 1000), () {
      if (aiProvider.manualCategory != null) return;
      if (titleController.text.trim().isNotEmpty) {
        aiProvider.requestClassification(titleController.text);
      }
    });
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

    // 2. DECISIÓN DE CATEGORÍA
    String finalCategory = aiProvider.manualCategory ?? aiProvider.suggestedCategory;

    // 3. SI NO HAY CATEGORÍA
    if (finalCategory.isEmpty || finalCategory == 'manual_category') {
      if (!mounted) return;

      final String? selectedManualCategory = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return const SelectCategoryWindow();
        },
      );

      if (selectedManualCategory != null) {
        finalCategory = selectedManualCategory;
      } else {
        return; // Canceló
      }
    }
    
    // 4. ACTUALIZAR
    final Transaction transactionActualizada = Transaction(
      fecha: widget.transaction.fecha,
      userId: widget.transaction.userId,
      saldo: widget.transaction.saldo,
      title: titleController.text,
      monto: enteredAmount,
      description: descriptionController.text,
      categoria: finalCategory,
      isExpense: isExpense,
    );
    
    if (!mounted) return;
    context.read<TransactionProvider>().updateTransaction(transactionActualizada);
    
    Navigator.of(context).pop();

    // Reseteamos el provider para la próxima vez
    aiProvider.resetCategory();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      // Aseguramos limpiar el provider si el usuario da "Atrás" sin guardar
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
           Provider.of<AiCategoryProvider>(context, listen: false).resetCategory();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.editTransaccionText,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: colorScheme.onSurface 
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
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
      ),
    );
  }
}