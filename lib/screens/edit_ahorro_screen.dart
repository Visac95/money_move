import 'dart:async';
import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/ahorro.dart';
import 'package:money_move/providers/ahorro_provider.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/widgets/ahorro_form.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:provider/provider.dart';

class EditAhorroScreen extends StatefulWidget {
  final Ahorro ahorro;

  const EditAhorroScreen({super.key, required this.ahorro});

  @override
  State<EditAhorroScreen> createState() => _EditAhorroScreenState();
}

class _EditAhorroScreenState extends State<EditAhorroScreen> {
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var amountController = TextEditingController();
  var involucradoController = TextEditingController();

  // 1. NUEVO: Controlador para la fecha y variable de estado
  final dateLimitController = TextEditingController();
  late DateTime _selectedDate;

  late bool debo;
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.ahorro.title;
    descriptionController.text =
        widget.ahorro.description; // No olvides cargar la descripción también
    amountController.text = widget.ahorro.monto.toStringAsFixed(2);

    // 3. Cargar la fecha que ya tiene la deuda
    _selectedDate = widget.ahorro.fechaMeta;
    dateLimitController.text = _formatDate(_selectedDate);

    // Listener para IA
    titleController.addListener(_classifyTitle);

    // PRE-CARGA DE CATEGORÍA EXISTENTE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final aiProvider = Provider.of<AiCategoryProvider>(
          context,
          listen: false,
        );
        aiProvider.manualCategory = widget.ahorro.categoria;
      }
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    involucradoController.dispose();
    dateLimitController.dispose(); // Limpieza del nuevo controller
    super.dispose();
  }

  // Helper para formato de fecha
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  // 4. Función para abrir calendario (Igual que en AddDeuda)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dateLimitController.text = _formatDate(picked);
      });
    }
  }

  void _classifyTitle() {
    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);

    if (aiProvider.manualCategory != null) return;

    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 1000), () {
      if (aiProvider.manualCategory != null) return;
      if (titleController.text.trim().isNotEmpty) {
        aiProvider.requestClassification(titleController.text);
      }
    });
  }

  Future<void> _saveDeuda(String emoji) async {
    if (titleController.text.isEmpty || amountController.text.isEmpty) return;

    double enteredAmount;
    try {
      enteredAmount = double.parse(amountController.text);
    } catch (e) {
      return;
    }

    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);

    String finalCategory =
        aiProvider.manualCategory ?? aiProvider.suggestedCategory;

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
        return;
      }
    }

    // 5. Actualizar Objeto con la nueva fecha
    final Ahorro ahorroActualizado = widget.ahorro.update(
      title: titleController.text,
      description:
          descriptionController.text, // Asegúrate de guardar la descripción
      monto: enteredAmount,
      fechaMeta: _selectedDate, // <--- AQUÍ GUARDAMOS LA NUEVA FECHA
      categoria: finalCategory,
    );

    if (!mounted) return;
    context.read<AhorroProvider>().updateAhorro(ahorroActualizado);

    Navigator.of(context).pop();

    aiProvider.resetCategory();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          Provider.of<AiCategoryProvider>(
            context,
            listen: false,
          ).resetCategory();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.editDeudaText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: colorScheme.onSurface),
        ),

        body: AhorroForm(
          titleController: titleController,
          descriptionController: descriptionController,
          amountController: amountController,

          // 6. Pasamos los controles de fecha al formulario
          dateController: dateLimitController,
          onDateTap: () => _selectDate(context),

          debo: debo,
          onTypeChanged: (bool value) {
            setState(() {
              debo = value;
            });
          },
          onSave: _saveDeuda,
          ahorro: widget
              .ahorro, // Opcional, dependiendo de cómo uses esto en DeudaForm
          isEditMode: true,
        ),
      ),
    );
  }
}
