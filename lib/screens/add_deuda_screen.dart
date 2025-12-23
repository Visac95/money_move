import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_move/models/deuda.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/widgets/deuda_form.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_value.dart';

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

    const uuid = Uuid();

    // --- GUARDAR ---
    deudaProvider.addDeuda(
      Deuda(
        id: uuid.v4(),
        title: titleController.text,
        description: "Sin descripción",
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

    // Reseteamos el provider para la próxima vez
    aiProvider.resetCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Añadir Deuda",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
