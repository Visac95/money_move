import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/utils/category_translater.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:provider/provider.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppLocalizations.of(context)!;

    final activeColor = isExpense ? AppColors.expense : AppColors.income;

    // --- LÓGICA DE ESTADO DEL BOTÓN ---
    final bool hasManual = aiProvider.manualCategory != null;
    final bool hasSuggestion = aiProvider.suggestedCategory.isNotEmpty;
    
    Color chipBgColor;
    Color chipBorderColor;
    Color chipTextColor;
    IconData chipIcon;
    String chipLabel;

    if (hasManual) {
      // 1. MANUAL (Usuario eligió) -> VERDE
      chipBgColor = Colors.green.withOpacity(isDark ? 0.2 : 0.1);
      chipBorderColor = Colors.green.withOpacity(0.5);
      chipTextColor = isDark ? Colors.greenAccent : Colors.green.shade700;
      chipIcon = Icons.check_circle;
      chipLabel = getCategoryName(context, aiProvider.manualCategory!);
    } else if (hasSuggestion) {
      // 2. SUGERENCIA IA -> COLOR PRIMARY
      chipBgColor = AppColors.brandPrimary.withOpacity(isDark ? 0.2 : 0.1);
      chipBorderColor = AppColors.brandPrimary.withOpacity(0.5);
      chipTextColor = isDark ? Colors.white : AppColors.brandPrimary;
      chipIcon = Icons.auto_awesome;
      chipLabel = "${strings.category}: ${getCategoryName(context, aiProvider.suggestedCategory)}";
    } else {
      // 3. ESTADO INICIAL (Ni manual, ni IA aún) -> GRIS / "CATEGORÍA"
      // Esto aparecerá apenas abras la pantalla
      chipBgColor = colorScheme.surfaceContainerHighest;
      chipBorderColor = Colors.transparent; 
      chipTextColor = colorScheme.onSurfaceVariant;
      chipIcon = Icons.category_outlined; 
      // Aquí forzamos que diga "Categoría" o "Seleccionar"
      chipLabel = strings.category; 
    }

    // Estilos inputs
    final inputDecorationTheme = InputDecoration(
      filled: true,
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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TÍTULO
            Text(
              strings.inputTitleTransactionText,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: inputDecorationTheme.copyWith(
                hintText: strings.writeTitleTransactionHint,
                prefixIcon: const Icon(Icons.edit_note_rounded),
              ),
            ),
            const SizedBox(height: 30),

            // 2. DESCRIPCIÓN
            Text(
              strings.descriptionTransactionText,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
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

            // 3. TOGGLE TIPO
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildToggleOption(context, strings.expencesText, true, activeColor),
                  _buildToggleOption(context, strings.incomeText, false, activeColor),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 4. MONTO
            Text(
              strings.amountText,
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: activeColor),
              decoration: InputDecoration(
                hintText: "0.00",
                hintStyle: TextStyle(color: colorScheme.outline.withOpacity(0.3)),
                prefixText: "\$ ",
                prefixStyle: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: activeColor),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            // 5. BOTÓN DE CATEGORÍA (Con AnimatedSwitcher)
            const SizedBox(height: 16),
            
            // La lógica es: Si está cargando -> Spinner.
            // Si NO está cargando (incluso al inicio) -> Botón configurado arriba (Estado 1, 2 o 3).
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: aiProvider.isLoading
                  ? Row(
                      key: const ValueKey('loading'),
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: activeColor),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          strings.analizingText,
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    )
                  : GestureDetector(
                      key: const ValueKey('button'),
                      onTap: () async {
                        final String? selectedManualCategory = await showDialog<String>(
                          context: context,
                          builder: (context) => const SelectCategoryWindow(),
                        );
                        
                        if (selectedManualCategory != null) {
                          aiProvider.manualCategory = selectedManualCategory;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: chipBgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: chipBorderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(chipIcon, size: 18, color: chipTextColor),
                            const SizedBox(width: 8),
                            Text(
                              chipLabel,
                              style: TextStyle(
                                color: chipTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down, size: 18, color: chipTextColor),
                          ],
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 40),

            // 6. GUARDAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.brandPrimary : AppColors.darkPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: Text(
                  strings.saveTransactionText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            color: isActive ? (isDark ? theme.colorScheme.surface : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive && !isDark
                ? [const BoxShadow(color: Color.fromARGB(30, 0, 0, 0), blurRadius: 4, offset: Offset(0, 2))]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? activeColor : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}