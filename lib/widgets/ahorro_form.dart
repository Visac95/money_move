import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/ahorro.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/utils/category_translater.dart';
import 'package:money_move/widgets/emoji_selector.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AhorroForm extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController amountController;
  // bool debo; // ELIMINADO: No es necesario saber si "debo" en un ahorro.
  // final Function(bool) onTypeChanged; // ELIMINADO: No se usaba en el build.
  final Function(String) onSave;
  final Ahorro? ahorro;
  final bool? isEditMode;
  final TextEditingController dateController;
  final VoidCallback onDateTap;

  const AhorroForm({
    // Agregado const para optimización
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.amountController,
    // required this.debo, // Eliminado para limpiar
    // required this.onTypeChanged, // Eliminado para limpiar
    required this.onSave,
    this.ahorro,
    this.isEditMode,
    required this.dateController,
    required this.onDateTap,
  });

  @override
  State<AhorroForm> createState() => _AhorroFormState();
}

class _AhorroFormState extends State<AhorroForm> {
  String _emojiSeleccionado = "💰"; // Valor por defecto

  @override
  void initState() {
    super.initState();
    if (widget.ahorro != null && widget.ahorro!.emoji.isNotEmpty) {
      _emojiSeleccionado = widget.ahorro!.emoji;
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiCategoryProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppLocalizations.of(context)!;

    // CAMBIO 1: Color fijo para Ahorros.
    // Los ahorros siempre son positivos (verde o color primario), no rojos como las deudas.
    final activeColor = AppColors.income;

    // --- LÓGICA DE ESTADO DEL BOTÓN DE CATEGORÍA ---
    final bool hasManual = aiProvider.manualCategory != null;
    final bool hasSuggestion = aiProvider.suggestedCategory.isNotEmpty;

    Color chipBgColor;
    Color chipBorderColor;
    Color chipTextColor;
    IconData chipIcon;
    String chipLabel;

    if (hasManual) {
      chipBgColor = Colors.green.withValues(alpha: isDark ? 0.2 : 0.1);
      chipBorderColor = Colors.green.withValues(alpha: 0.5);
      chipTextColor = isDark ? Colors.greenAccent : Colors.green.shade700;
      chipIcon = Icons.check_circle;
      chipLabel = getCategoryName(context, aiProvider.manualCategory!);
    } else if (hasSuggestion) {
      chipBgColor = colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1);
      chipBorderColor = colorScheme.primary.withValues(alpha: 0.5);
      chipTextColor = isDark ? Colors.white : colorScheme.primary;
      chipIcon = Icons.auto_awesome;
      chipLabel =
          "${strings.category}: ${getCategoryName(context, aiProvider.suggestedCategory)}";
    } else {
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
              strings.ahorroTitleText,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.titleController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: strings.ahorroEjTitleText,
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
            const SizedBox(height: 5), // Corregido const
            // 2. DESCRIPCIÓN
            Text(
              strings.ahorroDescriptionText,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: widget.descriptionController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: strings.optionalHintText,
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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

            //----DateLimit--------
            TextField(
              controller: widget.dateController,
              readOnly: true,
              onTap: widget.onDateTap,
              decoration: InputDecoration(
                labelText: strings.metaDateText,
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // Agregado color de foco para consistencia
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: activeColor, width: 2),
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
              controller: widget.amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                // Nota: Esto permite puntos. Si tus usuarios usan comas (Latam),
                // considera permitir ',' en el RegExp: RegExp(r'^\d+([.,]\d{0,2})?')
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
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
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

            const SizedBox(height: 15),

            // --- SECCIÓN AI / CATEGORÍA ---
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
            const SizedBox(height: 20),
            Center(
              child: Text(
                // Agregado const
                strings.chooseIconText,
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 10),

            EmojiSelector(
              selectedEmoji: _emojiSeleccionado,
              onEmojiSelected: (nuevoEmoji) {
                setState(() {
                  _emojiSeleccionado = nuevoEmoji;
                });
              },
            ),

            const SizedBox(height: 40),
            // Botón Guardar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(_emojiSeleccionado);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  strings.saveAhorroText, 
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
}
