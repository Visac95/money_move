import 'package:flutter/material.dart';
// import 'package:money_move/config/app_colors.dart'; // Ya no se necesita aquí
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
  String? manualCategory;

  @override
  void initState() {
    super.initState();
    titleController.addListener(_classifyTitle);
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

    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);

    // 2. OBTENEMOS LA CATEGORÍA SUGERIDA
    String categoryToSave = aiProvider.suggestedCategory;

    // 3. VERIFICAMOS SI HAY UNA CATEGORÍA MANUAL EN EL PROVIDER
    String? manualCategoryFromProvider = aiProvider.manualCategory;

    // Lógica de decisión:
    if (manualCategoryFromProvider != null) {
      categoryToSave = manualCategoryFromProvider;
    } else if (categoryToSave.isEmpty || categoryToSave == 'manual_category') {
      if (!mounted) return; // Seguridad

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

    // --- GUARDAR ---
    transactionProvider.addTransaction(
      Transaction(
        title: titleController.text,
        description: descriptionController.text,
        monto: enteredAmount,
        fecha: DateTime.now(),
        categoria: categoryToSave,
        isExpense: isExpense,
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }

    // Reseteamos el provider para la próxima vez
    aiProvider.resetCategory();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Acceso al tema actual

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // backgroundColor: AppColors.backgroundColor, // ELIMINADO: Automático por tema
      appBar: AppBar(
        title: Text(
          l10n.addTransaction,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            // Antes era transactionListIconColor (gris oscuro).
            // Ahora se adapta (Negro día / Blanco noche)
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent, // O colorScheme.surface
        elevation: 0,
        iconTheme: IconThemeData(
          color: colorScheme.onSurface, // Icono de atrás adaptable
        ),
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
