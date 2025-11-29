import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transactionProvider.dart'; // Ojo con la P mayúscula/minúscula según tu archivo
import '../models/transaction.dart';

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

  // Esta función se encarga de limpiar la memoria cuando cierras la pantalla
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // 2. Aquí va la función para guardar (la lógica del botón)
  void _saveTransaction() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      return;
    }

    // Usamos try-catch por si el usuario escribe letras en vez de números
    double enteredAmount;
    try {
      enteredAmount = double.parse(_amountController.text);
    } catch (e) {
      // Si falla la conversión, salimos (o podrías mostrar un error)
      return;
    }

    // 1. LISTEN: FALSE (Crucial para rendimiento en funciones)
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    transactionProvider.addTransaction(
      Transaction(
        // la id se genera sola
        title: _titleController.text,
        description:
            "Sin descripción", // Podrías agregar otro campo de texto luego
        monto: enteredAmount, // <--- AQUÍ CORREGIMOS EL BUG DEL 2.42
        fecha: DateTime.now(), // Usamos la fecha actual
        categoria: "General",
        isExpense: _isExpense, // <--- Usamos la variable del switch
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Movimiento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // CAJA DE TEXTO 1: Título
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),

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
