import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/ahorro.dart';
import 'package:money_move/providers/ahorro_provider.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:money_move/utils/mode_color_app_bar.dart';
import 'package:money_move/widgets/ahorro_form.dart';
import 'package:money_move/widgets/mode_toggle.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddAhorroScreen extends StatefulWidget {
  const AddAhorroScreen({super.key});

  @override
  State<AddAhorroScreen> createState() => _AddAhorroScreenState();
}

class _AddAhorroScreenState extends State<AddAhorroScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  // 1. Controlador para el texto de la fecha y variable para la fecha real
  final dateLimitController = TextEditingController();
  DateTime _selectedDate = DateTime.now(); // Por defecto hoy

  bool debo = true;
  bool generateAutoTransaction = true;
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    titleController.addListener(_classifyTitle);
    // Inicializamos el campo de texto con la fecha de hoy
    dateLimitController.text = _formatDate(_selectedDate);
  }

  @override
  void dispose() {
    debounce?.cancel();
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    dateLimitController.dispose(); // No olvidar liberar este controller
    super.dispose();
  }

  // Helper simple para formatear fecha (dd/MM/yyyy)
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  // 2. Función para abrir el calendario
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(
        2000,
      ), // Permitir fechas pasadas si es un registro antiguo
      lastDate: DateTime(2100),
      // Opcional: Personalizar colores del calendario si quieres
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme, // Usa los colores de tu app
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dateLimitController.text = _formatDate(
          picked,
        ); // Actualiza el texto visual
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

  Future<void> _saveDeuda(String emojiSeleccionado) async {
    if (titleController.text.isEmpty || amountController.text.isEmpty) return;

    double enteredAmount;
    try {
      enteredAmount = double.parse(amountController.text);
    } catch (e) {
      return;
    }

    final ahorroProv = Provider.of<AhorroProvider>(context, listen: false);
    //final transProvider = Provider.of<TransactionProvider>(context, listen: false,);
    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);

    String finalCategory =
        aiProvider.manualCategory ?? aiProvider.suggestedCategory;

    if (finalCategory.isEmpty || finalCategory == 'manual_category') {
      if (!mounted) return;
      final String? selectedManualCategory = await showDialog<String>(
        context: context,
        builder: (BuildContext context) => const SelectCategoryWindow(),
      );

      if (selectedManualCategory != null) {
        finalCategory = selectedManualCategory;
      } else {
        return;
      }
    }
    print("😶‍🌫️😶‍🌫️😶‍🌫️ 1");

    if (!mounted) {
      return;
    }

    final userProv = Provider.of<UserProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    print("😶‍🌫️😶‍🌫️😶‍🌫️ 2");

    const uuid = Uuid();
    final nuevaAhorro = Ahorro(
      userId: !transactionProvider.isSpaceMode
          ? FirebaseAuth.instance.currentUser!.uid
          : userProv.usuarioActual!.spaceId!,
      id: uuid.v4(),
      title: titleController.text,
      description: descriptionController.text,
      monto: enteredAmount,
      abono: 0.0,
      fechaInicio: DateTime.now(),
      fechaMeta: _selectedDate,
      categoria: finalCategory,
      ahorrado: false,
      emoji: emojiSeleccionado,
    );

    print("😶‍🌫️😶‍🌫️😶‍🌫️ 3");

    if (!mounted) return;
    ahorroProv.addAhorro(nuevaAhorro);

    print("😶‍🌫️😶‍🌫️😶‍🌫️ 4");

    if (mounted) Navigator.of(context).pop();
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
          l10n.addAhorroText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: modeColorAppbar(context, 0.4),
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [ModeToggle(bigWidget: false), SizedBox(width: 10)],
      ),
      // Pasamos los nuevos argumentos al DeudaForm
      body: AhorroForm(
        titleController: titleController,
        descriptionController: descriptionController,
        amountController: amountController,

        // Estos son los nuevos parámetros que debes recibir en DeudaForm:
        dateController: dateLimitController,
        onDateTap: () => _selectDate(context),
        onSave: _saveDeuda,
        isEditMode: false,
      ),
    );
  }
}
