import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:money_move/config/app_colors.dart'; // Ya no lo necesitamos aquí
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

  Future<void> _saveDeuda() async {
    // --- VALIDACIONES ---
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

    // 2. OBTENEMOS LA CATEGORÍA SUGERIDA
    String categoryToSave = aiProvider.suggestedCategory;

    // 3. VERIFICAMOS SI HAY UNA CATEGORÍA MANUAL EN EL PROVIDER
    String? manualCategoryFromProvider = aiProvider.manualCategory;

    if (manualCategoryFromProvider != null) {
      categoryToSave = manualCategoryFromProvider;
    } else if (categoryToSave.isEmpty || categoryToSave == 'manual_category') {
      if (!mounted) return; // Verificación de seguridad
      
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

    const uuid = Uuid();

    // --- GUARDAR ---
    deudaProvider.addDeuda(
      Deuda(
        id: uuid.v4(),
        title: titleController.text,
        description: l10n.noDescription,
        monto: enteredAmount,
        involucrado: involucradoController.text,
        abono: 0.0,
        fechaInicio: DateTime.now(),
        fechaLimite: DateTime(2026, 1, 1),
        categoria: categoryToSave,
        debo: debo,
        pagada: false,
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }

    aiProvider.resetCategory();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; 
    
    // Acceso al tema actual
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // backgroundColor: AppColors.white, // ELIMINADO: Ahora es automático
      
      appBar: AppBar(
        title: Text(
          l10n.addDeuda,
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            // El color se adapta automáticamente (negro/blanco)
            color: colorScheme.onSurface 
          ),
        ),
        backgroundColor: Colors.transparent, // O colorScheme.surface
        elevation: 0,
        // El icono de "atrás" también se adapta
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