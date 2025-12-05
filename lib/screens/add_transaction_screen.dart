import 'package:flutter/material.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'dart:async';
import '../config/app_colors.dart'; // Asegúrate de importar tus colores
import 'package:flutter/services.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isExpense = true;
  Timer? _debounce;
  String? _manualCategory;
  

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_classifyTitle);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _classifyTitle() {
    if (_manualCategory != null) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      final aiProvider = Provider.of<AiCategoryProvider>(
        context,
        listen: false,
      );
      aiProvider.requestClassification(_titleController.text);
    });
  }

  Future<void> _saveTransaction() async {
    // --- VALIDACIONES ---
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;

    double enteredAmount;
    try {
      enteredAmount = double.parse(_amountController.text);
    } catch (e) {
      return;
    }

    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

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

    // --- GUARDAR ---
    transactionProvider.addTransaction(
      Transaction(
        title: _titleController.text,
        description: "Sin descripción",
        monto: enteredAmount,
        fecha: DateTime.now(),
        categoria: categoryToSave,
        isExpense: _isExpense,
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
    final aiProvider = context.watch<AiCategoryProvider>();

    // Color dinámico según selección
    final activeColor = _isExpense
        ? AppColors.expenseColor
        : AppColors.incomeColor;
    String? manualCategory = aiProvider
        .manualCategory; // Si es null, usamos la IA. Si tiene texto, usamos este.
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Nuevo Movimiento',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOGGLE PERSONALIZADO (Gasto vs Ingreso)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildToggleOption("Gasto", true),
                    _buildToggleOption("Ingreso", false),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 2. INPUT DE MONTO (Gigante, estilo banco)
              const Text(
                "Monto",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(

                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ),
                decoration: InputDecoration(
                  hintText: "0.00",
                  prefixText: "\$ ",
                  prefixStyle: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: activeColor,
                  ),
                  border: InputBorder.none, // Sin borde, super limpio
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              const SizedBox(height: 30),

              // 3. INPUT DE TÍTULO
              const Text(
                "Descripción",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "¿En qué gastaste?",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  prefixIcon: Icon(
                    Icons.edit_note_rounded,
                    color: Colors.grey.shade400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                ),
              ),

              // 4. CHIP DE IA / CATEGORÍA (Con lógica de bloqueo)
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: aiProvider.isLoading
                    ? Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: activeColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Analizando...",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      )
                    : (aiProvider.suggestedCategory.isNotEmpty ||
                          manualCategory !=
                              null) // Mostramos si hay IA o Manual
                    ? GestureDetector(
                        // <--- AQUÍ HACEMOS LA MAGIA
                        onTap: () async {
                          // Abrimos el selector manual
                          final String? selectedManualCategory =
                              await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) {
                                  return SelectCategoryWindow();
                                },
                              );
                          if (selectedManualCategory != null) {
                            aiProvider.manualCategory = selectedManualCategory;
                            manualCategory = selectedManualCategory;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            // Cambiamos el color si es manual para dar feedback visual
                            color: _manualCategory != null
                                ? Colors.green.shade50
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: manualCategory != null
                                  ? Colors.green.shade200
                                  : AppColors.primaryColor,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Cambiamos el ícono: Estrellitas si es IA, Check si es Manual
                              Icon(
                                manualCategory != null
                                    ? Icons.check_circle
                                    : Icons.auto_awesome,
                                size: 16,
                                color: manualCategory != null
                                    ? Colors.green
                                    : AppColors.primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                // Mostramos la manual si existe, si no, la de la IA
                                manualCategory != null
                                    ? "Categoría: $manualCategory"
                                    : "Sugerencia: ${aiProvider.suggestedCategory}",
                                style: TextStyle(
                                  color: _manualCategory != null
                                      ? Colors.green.shade700
                                      : AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // Flechita pequeña para indicar que se puede cambiar
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: _manualCategory != null
                                    ? Colors.green
                                    : AppColors.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 40),

              // 5. BOTÓN DE GUARDAR (Full Width)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryDark, // Botón negro moderno
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Guardar Movimiento",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para construir los botones del Toggle
  Widget _buildToggleOption(String label, bool isExpenseButton) {
    // Si _isExpense es true y este botón es el de gasto (isExpenseButton == true) -> ACTIVO
    bool isActive = _isExpense == isExpenseButton;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpense = isExpenseButton;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color.fromARGB(133, 0, 0, 0),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive
                  ? (isExpenseButton
                        ? AppColors.expenseColor
                        : AppColors.incomeColor)
                  : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
