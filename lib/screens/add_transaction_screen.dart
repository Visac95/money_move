import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart'; // Ojo con la P mayúscula/minúscula según tu archivo
import '../models/transaction.dart';
import 'dart:async'; // <--- IMPORTANTE
import '../config/app_constants.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // 1. Aquí declaramos los "Controladores" (nuestras variables para el texto)
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isExpense = true; // Por defecto será gasto

  // En _AddTransactionScreenState
  @override
  void initState() {
    super.initState();
    // Cada vez que el texto cambie, llama a _classifyTitle
    _titleController.addListener(_classifyTitle);
  }

  // ... (El resto de la clase, incluyendo el método dispose)

  Timer? _debounce; // Variable para controlar el tiempo

  @override
  void dispose() {
    _debounce?.cancel(); // Cancelar el timer si cerramos la pantalla
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _classifyTitle() {
    // Si hay un timer corriendo (el usuario sigue escribiendo), lo cancelamos
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Iniciamos un nuevo timer de 500 milisegundos
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      // ESTO SOLO SE EJECUTA SI PASAN 0.5s SIN ESCRIBIR
      final aiProvider = Provider.of<AiCategoryProvider>(
        context,
        listen: false,
      );
      aiProvider.requestClassification(_titleController.text);
    });
  }

  // 2. Aquí va la función para guardar (la lógica del botón)
  // 1. Convertimos la función principal en ASYNC para poder esperar al usuario
  Future<void> _saveTransaction() async {
    // --- VALIDACIONES ---
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      return;
    }

    double enteredAmount;
    try {
      enteredAmount = double.parse(_amountController.text);
    } catch (e) {
      return;
    }

    // --- PREPARACIÓN DE PROVIDERS ---
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    final aiProvider = Provider.of<AiCategoryProvider>(context, listen: false);

    // --- LÓGICA DE DECISIÓN DE CATEGORÍA ---
    String categoryToSave = aiProvider.suggestedCategory;

    // Si la categoría está vacía o es la bandera de "manual", abrimos el diálogo
    if (categoryToSave.isEmpty || categoryToSave == 'manual_category') {
      // AWAIT: El código se DETIENE aquí hasta que el usuario elija y se cierre el diálogo
      final String? selectedManualCategory = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              AppConstants.chooseCategoryManualTitle ?? 'Elige una categoría',
            ), // Asegúrate de que no sea null
            // SENIOR TIP: Usamos .map para no repetir código 8 veces
            children: AppConstants.categories.map((categoryItem) {
              return SimpleDialogOption(
                onPressed: () {
                  // ESTO ES CLAVE: Navigator.pop cierra el diálogo y devuelve 'cat'
                  Navigator.pop(context, categoryItem);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(AppConstants.getIconForCategory(categoryItem)),
                      Text(categoryItem, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      );

      // Si el usuario cerró el diálogo sin elegir nada (clic afuera), selectedManualCategory será null
      if (selectedManualCategory != null) {
        categoryToSave = selectedManualCategory;
      } else {
        // Si canceló, detenemos el guardado
        return;
      }
    }

    // --- GUARDADO FINAL ---
    transactionProvider.addTransaction(
      Transaction(
        title: _titleController.text,
        description: "Sin descripción",
        monto: enteredAmount,
        fecha: DateTime.now(),
        categoria:
            categoryToSave, // <--- Aquí va la categoría final (IA o Manual)
        isExpense: _isExpense,
      ),
    );
    // Cerramos la pantalla de agregar
    if (mounted) {
      Navigator.of(context).pop();
    }
    aiProvider.resetCategory();
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios del proveedor de la IA
    final aiProvider = context.watch<AiCategoryProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Movimiento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // CAJA DE TEXTO 1: Título
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título del Gasto/Ingreso',
              ),
            ),
            // --- SUGERENCIA DE LA IA ---
            aiProvider.isLoading
                ? const LinearProgressIndicator() // Si está cargando, muestra la barra
                : Text(
                    'Categoria: ${aiProvider.suggestedCategory == 'manual_category' ? "" : aiProvider.suggestedCategory}',
                  ),
            // --- FIN SUGERENCIA DE LA IA ---
            // CAJA DE TEXTO 2: Monto
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Monto'),
              keyboardType: TextInputType.number, // Teclado numérico
            ), // Selector de Tipo de Movimiento
            Row(
              children: [
                Text(_isExpense ? 'Gasto 📉' : 'Ingreso 📈'),
                Switch(
                  value: _isExpense,
                  onChanged: (val) {
                    setState(() {
                      _isExpense = val; // Esto actualiza la UI
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // BOTÓN DE GUARDAR
            ElevatedButton(
              onPressed: _saveTransaction,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
