import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/deuda.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/widgets/deuda_form.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:provider/provider.dart';

class EditDeudaScreen extends StatefulWidget {
  final Deuda deuda;

  const EditDeudaScreen({super.key, required this.deuda});

  @override
  State<EditDeudaScreen> createState() => _EditDeudaScreenState();
}

class _EditDeudaScreenState extends State<EditDeudaScreen> {
  var titleController = TextEditingController();
  var amountController = TextEditingController();
  var involucradoController = TextEditingController();

  late bool debo;
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    // 1. Carga de datos de texto
    debo = widget.deuda.debo;
    titleController.text = widget.deuda.title;
    amountController.text = widget.deuda.monto.toStringAsFixed(2);
    involucradoController.text = widget.deuda.involucrado;

    // 2. Listener para IA
    titleController.addListener(_classifyTitle);

    // 3. PRE-CARGA DE CATEGORÍA EXISTENTE (Lógica de Edit)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final aiProvider = Provider.of<AiCategoryProvider>(
          context,
          listen: false,
        );
        // Pre-cargamos como manual para que salga VERDE y la IA no moleste
        aiProvider.manualCategory = widget.deuda.categoria;
      }
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    titleController.dispose();
    amountController.dispose();
    involucradoController.dispose();
    super.dispose();
  }

  // --- LÓGICA IA ---
  void _classifyTitle() {
    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);

    // Si ya hay manual, no hacemos nada
    if (aiProvider.manualCategory != null) return;

    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 1000), () {
      if (aiProvider.manualCategory != null) return;
      if (titleController.text.trim().isNotEmpty) {
        aiProvider.requestClassification(titleController.text);
      }
    });
  }

  Future<void> _saveDeuda() async {
    // 1. Validaciones
    if (titleController.text.isEmpty || amountController.text.isEmpty) return;

    double enteredAmount;
    try {
      enteredAmount = double.parse(amountController.text);
    } catch (e) {
      return;
    }

    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);

    // 2. Resolver Categoría
    String finalCategory = aiProvider.manualCategory ?? aiProvider.suggestedCategory;

    // 3. Si no hay categoría, forzar popup
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

    // 4. Actualizar Objeto
    // Asegúrate de que tu modelo Deuda tenga el método copyWith o update con estos parámetros
    final Deuda deudaActualizada = widget.deuda.update(
      title: titleController.text,
      monto: enteredAmount,
      involucrado: involucradoController.text, // Corregido: mapeado a 'involucrado', no description
      categoria: finalCategory,
      debo: debo,
    );

    if (!mounted) return;
    context.read<DeudaProvider>().updateDeuda(deudaActualizada);

    Navigator.of(context).pop();

    // Limpieza
    aiProvider.resetCategory();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      // Limpiamos provider si sale sin guardar
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
           Provider.of<AiCategoryProvider>(context, listen: false).resetCategory();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.editDeudaText,
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
          onTypeChanged: (bool value) {
            setState(() {
              debo = value;
            });
          },
          onSave: _saveDeuda,
          deuda: widget.deuda,
          isEditMode: true,
        ),
      ),
    );
  }
}