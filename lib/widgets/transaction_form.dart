import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/utils/category_translater.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart'; 
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class TransactionForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController amountController;

  bool isExpense;

  final Function(bool) onTypeChanged; 
  final VoidCallback onSave; 

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
    
    // Accedemos al tema actual
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Color dinámico según selección (Gasto / Ingreso)
    final activeColor = isExpense
        ? AppColors.expense
        : AppColors.income;
        
    String? manualCategory = aiProvider.manualCategory;

    // Estilo común para los inputs
    final inputDecorationTheme = InputDecoration(
      filled: true,
      // Color de fondo adaptable: Gris suave en Light, Gris oscuro en Dark
      fillColor: colorScheme.surfaceContainerHighest, 
      prefixIconColor: colorScheme.onSurfaceVariant,
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: activeColor, width: 2),
      ),
    );
    
    final strings = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. INPUT DE TÍTULO
            Text(
              strings.inputTitleTransactionText,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant, 
                fontWeight: FontWeight.w600
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              style: TextStyle(color: colorScheme.onSurface), // Color del texto al escribir
              decoration: inputDecorationTheme.copyWith(
                hintText: strings.writeTitleTransactionHint,
                prefixIcon: const Icon(Icons.edit_note_rounded),
              ),
            ),
            const SizedBox(height: 30),

            // 2. INPUT DE DESCRIPCIÓN
            Text(
              strings.descriptionTransactionText,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant, 
                fontWeight: FontWeight.w600
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: inputDecorationTheme.copyWith(
                hintText: strings.optionalHintText,
                prefixIcon: const Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 30),

            // 3. TOGGLE PERSONALIZADO (Gasto vs Ingreso)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                // Fondo del contenedor del toggle
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildToggleOption(context, strings.incomeText, true, activeColor),
                  _buildToggleOption(context, strings.expenseText, false, activeColor),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 4. INPUT DE MONTO
            Text(
              strings.amountText,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant, 
                fontWeight: FontWeight.w600
              ),
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
                hintStyle: TextStyle(color: colorScheme.outline.withOpacity(0.3)),
                prefixText: "\$ ",
                prefixStyle: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            // 5. CHIP DE IA / CATEGORÍA
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
                        Text(
                          strings.analizingText,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant, 
                            fontSize: 12
                          ),
                        ),
                      ],
                    )
                  : (aiProvider.suggestedCategory.isNotEmpty || manualCategory != null)
                      ? GestureDetector(
                          onTap: () async {
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
                              // Usamos withOpacity para que funcione en Dark Mode
                              color: manualCategory != null
                                  ? Colors.green.withOpacity(isDark ? 0.2 : 0.1)
                                  : AppColors.brandPrimary.withOpacity(isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: manualCategory != null
                                    ? Colors.green.withOpacity(0.5)
                                    : AppColors.brandPrimary.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  manualCategory != null
                                      ? Icons.check_circle
                                      : Icons.auto_awesome,
                                  size: 16,
                                  color: manualCategory != null
                                      ? (isDark ? Colors.greenAccent : Colors.green)
                                      : (isDark ? AppColors.accent : AppColors.brandPrimary),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  manualCategory != null
                                      ? strings.selectCategoryText
                                      : "${strings.category}: ${getCategoryName(context, aiProvider.suggestedCategory)}",
                                  style: TextStyle(
                                    color: manualCategory != null
                                        ? (isDark ? Colors.greenAccent : Colors.green.shade700)
                                        : (isDark ? Colors.white : AppColors.brandPrimary),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
            ),

            const SizedBox(height: 40),

            // 6. BOTÓN DE GUARDAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  // En dark mode, el negro no se ve. Usamos primaryColor o blanco invertido.
                  backgroundColor: isDark ? AppColors.brandPrimary : AppColors.darkPrimary,
                  foregroundColor: isDark ? Colors.white : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child:  Text(
                  strings.saveTransactionText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
  Widget _buildToggleOption(BuildContext context, String label, bool isExpenseButton, Color activeColor) {
    bool isActive = isExpense == isExpenseButton;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(isExpenseButton),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            // El fondo del botón activo cambia según el tema
            color: isActive 
                ? (isDark ? theme.colorScheme.surface : Colors.white) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive && !isDark // Sin sombra en modo oscuro
                ? [
                    const BoxShadow(
                      color: Color.fromARGB(30, 0, 0, 0),
                      blurRadius: 4,
                      offset: Offset(0, 2),
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
                  ? activeColor
                  : theme.colorScheme.onSurfaceVariant, // Color inactivo adaptable
            ),
          ),
        ),
      ),
    );
  }
}