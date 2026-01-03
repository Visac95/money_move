import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/deuda.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/utils/category_translater.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class DeudaForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController amountController;
  final TextEditingController involucradoController;
  bool debo;
  final Function(bool) onTypeChanged;
  final VoidCallback onSave;
  final Deuda? deuda;
  final bool? isEditMode;
  final TextEditingController dateController;
  final VoidCallback onDateTap;

  DeudaForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.amountController,
    required this.involucradoController,
    required this.debo,
    required this.onTypeChanged,
    required this.onSave,
    this.deuda,
    this.isEditMode,
    required this.dateController,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos watch para reconstruir si cambia el estado del provider (IA o Manual)
    final aiProvider = context.watch<AiCategoryProvider>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppLocalizations.of(context)!;

    final activeColor = debo ? AppColors.accent : AppColors.income;

    // --- LÓGICA DE ESTADO DEL BOTÓN DE CATEGORÍA ---
    // La lógica ahora es universal: EditDeudaScreen ya cargó la categoría en 'manualCategory'
    final bool hasManual = aiProvider.manualCategory != null;
    final bool hasSuggestion = aiProvider.suggestedCategory.isNotEmpty;

    Color chipBgColor;
    Color chipBorderColor;
    Color chipTextColor;
    IconData chipIcon;
    String chipLabel;

    if (hasManual) {
      // 1. MANUAL (Usuario eligió o estamos editando una existente) -> VERDE
      chipBgColor = Colors.green.withValues(alpha:isDark ? 0.2 : 0.1);
      chipBorderColor = Colors.green.withValues(alpha:0.5);
      chipTextColor = isDark ? Colors.greenAccent : Colors.green.shade700;
      chipIcon = Icons.check_circle;
      chipLabel = getCategoryName(context, aiProvider.manualCategory!);
    } else if (hasSuggestion) {
      // 2. SUGERENCIA IA -> COLOR PRIMARY
      chipBgColor = colorScheme.primary.withValues(alpha:isDark ? 0.2 : 0.1);
      chipBorderColor = colorScheme.primary.withValues(alpha:0.5);
      chipTextColor = isDark ? Colors.white : colorScheme.primary;
      chipIcon = Icons.auto_awesome;
      chipLabel =
          "${strings.category}: ${getCategoryName(context, aiProvider.suggestedCategory)}";
    } else {
      // 3. ESTADO INICIAL -> GRIS / "CATEGORÍA"
      chipBgColor = colorScheme.surfaceContainerHighest;
      chipBorderColor = Colors.transparent;
      chipTextColor = colorScheme.onSurfaceVariant;
      chipIcon = Icons.category_outlined;
      chipLabel = strings.category;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //-----Titulo---------
            Text(
              strings.deudaTitleText,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: strings.deudaEjTitleText,
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha:0.5),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
                prefixIcon: Icon(
                  Icons.edit_note_rounded,
                  color: colorScheme.onSurfaceVariant,
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
            SizedBox(height: 5),
            // 2. DESCRIPCIÓN
            Text(
              strings.debtdescriptionText,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: descriptionController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: strings.optionalHintText,
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha:0.5),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
                prefixIcon: Icon(
                  Icons.edit_note_rounded,
                  color: colorScheme.onSurfaceVariant,
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

            // --- TOGGLE SWITCH (Yo debo / Me deben) ---
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildToggleOption(context, strings.yoDeboText, true),
                  _buildToggleOption(context, strings.meDebenText, false),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Input Involucrado
            Text(
              _involucradoText(context),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: involucradoController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: strings.involucradoNameHint,
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha:0.5),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
                prefixIcon: Icon(
                  Icons.person,
                  color: colorScheme.onSurfaceVariant,
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
            const SizedBox(height: 20),

            //----DateLimit--------
            // Ejemplo de TextField para la fecha
            TextField(
              controller: dateController, // El controlador que le pasamos
              readOnly: true, // Importante: para que no escriban, solo toquen
              onTap: onDateTap, // Al tocar, se abre el calendario
              decoration: InputDecoration(
                labelText: strings.limitDateText, // O usa AppLocalizations
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Input Monto
            const SizedBox(height: 20),
            Text(
              strings.amountText,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
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
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha:0.3),
                ),
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

            const SizedBox(height: 16),

            // --- SECCIÓN AI / CATEGORÍA (OPTIMIZADA) ---
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: aiProvider.isLoading
                  ? Row(
                      key: const ValueKey('loading'),
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
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      key: const ValueKey('button'),
                      onTap: () async {
                        final String? selectedManualCategory =
                            await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return const SelectCategoryWindow();
                              },
                            );
                        // Si selecciona algo, actualizamos el Provider (esto pone el botón verde)
                        if (selectedManualCategory != null) {
                          aiProvider.manualCategory = selectedManualCategory;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: chipBgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: chipBorderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(chipIcon, size: 16, color: chipTextColor),
                            const SizedBox(width: 6),
                            Text(
                              chipLabel,
                              style: TextStyle(
                                color: chipTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: chipTextColor,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 40),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  strings.saveDeudaText,
                  style: const TextStyle(
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

  String _involucradoText(BuildContext context) {
    if (debo) {
      return AppLocalizations.of(context)!.quienMeDebeText;
    } else {
      return AppLocalizations.of(context)!.quienLeDeboText;
    }
  }

  Widget _buildToggleOption(
    BuildContext context,
    String label,
    bool deboButton,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    bool isActive = debo == deboButton;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeChanged(deboButton),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: (isActive && !isDark)
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.1),
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
                  ? (deboButton ? AppColors.accent : AppColors.income)
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
