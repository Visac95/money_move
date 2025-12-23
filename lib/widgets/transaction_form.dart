import 'package:flutter/material.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart'; // Asegúrate de importar tus colores
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class TransactionForm extends StatelessWidget {
  // Recibe los controles desde el padre
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController amountController;

  // Recibe el estado actual
  bool isExpense;

  // Recibe FUNCIONES (Callbacks) para avisar al padre cuando algo cambia
  final Function(bool) onTypeChanged; // Avisa si cambió de Gasto a Ingreso
  final VoidCallback onSave; // Avisa cuando le dieron click al botón guardar

  final Transaction? transaction;
  final bool? isEditMode;

  TransactionForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.amountController,
    required this.isExpense,
    required this.onTypeChanged,
    required this.onSave,
    this.transaction,
    this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiCategoryProvider>();

    // Color dinámico según selección
    final activeColor = isExpense
        ? AppColors.expenseColor
        : AppColors.incomeColor;
    String? manualCategory = aiProvider
        .manualCategory; // Si es null, usamos la IA. Si tiene texto, usamos este.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. INPUT DE TÍTULO
            const Text(
              "Título de la Transacción",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Escribe el titulo de tu movimiento",
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
            const SizedBox(height: 30),

            // 3. INPUT DE Description
            const Text(
              "Descripción de la Transacción",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: "Opcional",
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
            const SizedBox(height: 30),

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
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
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
                        manualCategory != null) // Mostramos si hay IA o Manual
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
                          color: manualCategory != null
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
                                  ? "Selecione una categoría."
                                  : "Categoría: ${aiProvider.suggestedCategory}",
                              style: TextStyle(
                                color: manualCategory != null
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
                              color: manualCategory != null
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
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark, // Botón negro moderno
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
    );
  }

  // Helper para construir los botones del Toggle
  Widget _buildToggleOption(String label, bool isExpenseButton) {
    // Si _isExpense es true y este botón es el de gasto (isExpenseButton == true) -> ACTIVO
    bool isActive = isExpense == isExpenseButton;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(isExpenseButton),
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
