import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:money_move/widgets/transaction_form.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'dart:async';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isExpense = true;
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    // Escuchamos cambios en el título para activar la IA
    titleController.addListener(_classifyTitle);
  }

  @override
  void dispose() {
    debounce?.cancel();
    titleController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // --- LÓGICA IA LIMPIA ---
  void _classifyTitle() {
    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);
    aiProvider.resetCategory();

    // 1. REGLA DE ORO: Si el usuario ya eligió manualmente, la IA no hace NADA.
    if (aiProvider.manualCategory != null) return;

    // Debounce para no llamar a la API por cada letra
    if (debounce?.isActive ?? false) debounce!.cancel();
    
    debounce = Timer(const Duration(milliseconds: 1000), () {
      // Doble chequeo por si el usuario eligió una categoría mientras corría el timer
      if (aiProvider.manualCategory != null) return;
      
      // Si el título no está vacío, pedimos ayuda a la IA
      if (titleController.text.trim().isNotEmpty) {
        aiProvider.requestClassification(titleController.text);
      }
    });
  }

  Future<void> _saveTransaction() async {
    // 1. Validaciones básicas
    if (titleController.text.isEmpty || amountController.text.isEmpty) return;

    final double? enteredAmount = double.tryParse(amountController.text);
    if (enteredAmount == null) return;

    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    // 2. DECISIÓN DE CATEGORÍA (Lógica simplificada)
    // Prioridad: 1. Manual -> 2. Sugerencia IA -> 3. Vacío
    String finalCategory = aiProvider.manualCategory ?? aiProvider.suggestedCategory;

    // 3. SI NO HAY CATEGORÍA (La IA falló/no respondió y el usuario no eligió)
    // Forzamos a elegir manualmente ahora.
    if (finalCategory.isEmpty || finalCategory == 'manual_category') {
      if (!mounted) return;
      
      final String? selectedManual = await showDialog<String>(
        context: context,
        builder: (context) => const SelectCategoryWindow(),
      );

      if (selectedManual != null) {
        finalCategory = selectedManual;
      } else {
        return; // Usuario canceló el diálogo, no guardamos.
      }
    }

    // 4. GUARDAR
    transactionProvider.addTransaction(
      Transaction(
        title: titleController.text,
        description: descriptionController.text,
        monto: enteredAmount,
        fecha: DateTime.now(),
        categoria: finalCategory,
        isExpense: isExpense,
      ),
    );

    if (mounted) Navigator.of(context).pop();
    
    // Limpieza final
    aiProvider.resetCategory();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.addTransaction,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
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
      ),
    );
  }
}