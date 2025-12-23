import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/models/deuda.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class DeudaForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController involucradoController;
  bool debo;
  final Function(bool) onTypeChanged;
  final VoidCallback onSave;
  final Deuda? deuda;
  final bool? isEditMode;

  DeudaForm({
    super.key,
    required this.titleController,
    required this.amountController,
    required this.involucradoController,
    required this.debo,
    required this.onTypeChanged,
    required this.onSave,
    this.deuda,
    this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiCategoryProvider>();

    final activeColor = debo ? AppColors.expenseColor : AppColors.incomeColor;
    String? manualCategory = aiProvider.manualCategory;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Titulo de la Deuda",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Ej. Compra de zapatos",
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

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildToggleOption("Yo debo", true),
                  _buildToggleOption("Me deben", false),
                ],
              ),
            ),

            const SizedBox(height: 15),

            //Involucrado input
            Text(
              _involucradoText(),
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: involucradoController,
              decoration: InputDecoration(
                hintText: "Nombre del involucrado",
                filled: true,
                fillColor: Colors.grey.shade50,
                prefixIcon: Icon(
                  Icons.person,
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
                  "Guardar Deuda",
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

  String _involucradoText() {
    if (debo) {
      return "A quien le debo";
    } else {
      return "Quien me debe";
    }
  }

  // Helper para construir los botones del Toggle
  Widget _buildToggleOption(String label, bool deboButton) {
    // Si _isExpense es true y este botón es el de gasto (isExpenseButton == true) -> ACTIVO
    bool isActive = debo == deboButton;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(deboButton),
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
                  ? (deboButton
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
