import 'package:flutter/material.dart';
import 'package:money_move/models/transaction.dart';
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

  late bool isExpense;
  Timer? debounce;
  String? manualCategory;

  @override
  void initState() {
    super.initState();
    //titleController.addListener(_classifyTitle);
    // 1. Cargamos el booleano (esto ya lo tenías)
    isExpense = widget.transaction.isExpense;

    // 2. ¡IMPORTANTE! Cargamos los textos AQUÍ una sola vez
    titleController.text = widget.transaction.title;

    // Ojo: toStringAsFixed(2) para que se vea bonito "15.50"
    amountController.text = widget.transaction.monto.toStringAsFixed(2);
  }

  @override
  void dispose() {
    debounce?.cancel();
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _classifyTitle() {
    if (manualCategory != null) return;

    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 1000), () {
      final aiProvider = Provider.of<AiCategoryProvider>(
        context,
        listen: false,
      );
      aiProvider.requestClassification(titleController.text);
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
    // 1. OBTENEMOS EL PROVIDER UNA SOLA VEZ (con listen: false)
    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);

    // 2. OBTENEMOS LA CATEGORÍA SUGERIDA
    String categoryToSave = aiProvider.suggestedCategory;

    // --- AQUÍ ESTABA EL ERROR, BORRÉ LA SEGUNDA DECLARACIÓN ---

    // 3. VERIFICAMOS SI HAY UNA CATEGORÍA MANUAL EN EL PROVIDER
    // Usamos la misma variable 'aiProvider' que declaramos arriba
    String? manualCategoryFromProvider = aiProvider.manualCategory;

    // Lógica de decisión:
    if (manualCategoryFromProvider != null) {
      // Si el usuario eligió manual, usamos esa
      categoryToSave = manualCategoryFromProvider;
    } else if (categoryToSave.isEmpty || categoryToSave == 'manual_category') {
      // Si no hay manual y la IA falló, abrimos ventana
      final String? selectedManualCategory = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return const SelectCategoryWindow(); // Asumo que este widget existe
        },
      );

      if (selectedManualCategory != null) {
        categoryToSave = selectedManualCategory;
      } else {
        return; // Canceló
      }
    }

    // 4. ACTUALIZAMOS LA TRANSACCIÓN
    widget.transaction.update(
      title: titleController.text,
      monto: enteredAmount,
      categoria: manualCategoryFromProvider ?? categoryToSave,
      isExpense: isExpense,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }

    // Reseteamos el provider para la próxima vez
    aiProvider.resetCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Editar Movimiento',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: TransactionForm(
        titleController: titleController,
        amountController: amountController,
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
