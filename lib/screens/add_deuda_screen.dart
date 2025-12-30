import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart'; 
import 'package:money_move/models/deuda.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/widgets/deuda_form.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddDeudaScreen extends StatefulWidget {
  const AddDeudaScreen({super.key});

  @override
  State<AddDeudaScreen> createState() => _AddDeudaScreenState();
}

class _AddDeudaScreenState extends State<AddDeudaScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final involucradoController = TextEditingController();
  bool debo = true;
  Timer? debounce;
  // Eliminado: String? manualCategory; (Ya no lo necesitamos localmente)

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
    involucradoController.dispose();
    super.dispose();
  }

  // --- LÓGICA IA OPTIMIZADA ---
  void _classifyTitle() {
    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);

    // 1. REGLA DE ORO: Si ya hay manual, cancelamos IA.
    if (aiProvider.manualCategory != null) return;

    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 1000), () {
      // Doble chequeo por seguridad
      if (aiProvider.manualCategory != null) return;
      
      if (titleController.text.trim().isNotEmpty) {
        aiProvider.requestClassification(titleController.text);
      }
    });
  }

  Future<void> _saveDeuda() async {
    // 1. Validaciones básicas
    if (titleController.text.isEmpty || amountController.text.isEmpty) return;

    double enteredAmount;
    try {
      enteredAmount = double.parse(amountController.text);
    } catch (e) {
      return;
    }

    final deudaProvider = Provider.of<DeudaProvider>(context, listen: false);
    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    // 2. DECISIÓN DE CATEGORÍA
    // Prioridad: Manual > IA
    String finalCategory = aiProvider.manualCategory ?? aiProvider.suggestedCategory;

    // 3. SI NO HAY CATEGORÍA (Ni manual, ni IA)
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
        return; // Usuario canceló
      }
    }

    const uuid = Uuid();

    // 4. GUARDAR
    deudaProvider.addDeuda(
      Deuda(
        id: uuid.v4(),
        title: titleController.text,
        description: l10n.noDescription, // O usa un controller si lo agregas luego
        monto: enteredAmount,
        involucrado: involucradoController.text,
        abono: 0.0,
        fechaInicio: DateTime.now(),
        fechaLimite: DateTime(2026, 1, 1), // Ojo: Esto es hardcodeado, quizás quieras un DatePicker luego
        categoria: finalCategory,
        debo: debo,
        pagada: false,
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }

    // Limpieza
    aiProvider.resetCategory();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; 
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.addDeuda,
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: colorScheme.onSurface 
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: DeudaForm(
        titleController: titleController,
        amountController: amountController,
        involucradoController: involucradoController,
        debo: debo,
        onTypeChanged: (bool value){
          setState(() {
            debo = value;
          });
        },
        onSave: _saveDeuda,
      ),
    );
  }
}