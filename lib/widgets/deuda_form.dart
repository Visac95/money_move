import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/deuda.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/widgets/select_category_window.dart';
import 'package:path/path.dart';
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
    
    // Acceso al tema actual
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activeColor = debo ? AppColors.expense : AppColors.income;
    String? manualCategory = aiProvider.manualCategory;

    final strings = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.deudaTitleText,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant, // Gris adaptable
                fontWeight: FontWeight.w600
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              style: TextStyle(color: colorScheme.onSurface), // Color del texto al escribir
              decoration: InputDecoration(
                hintText: strings.deudaEjTitleText,
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                filled: true,
                // Fondo del input adaptable
                fillColor: colorScheme.surfaceContainer, 
                prefixIcon: Icon(
                  Icons.edit_note_rounded,
                  color: colorScheme.onSurfaceVariant, // Icono adaptable
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

            // --- TOGGLE SWITCH ---
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                // Fondo del contenedor del toggle
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

            // Involucrado input
            Text(
              _involucradoText(context),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant, 
                fontWeight: FontWeight.w600
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: involucradoController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: strings.involucradoNameHint,
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
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

            // 2. INPUT DE MONTO (Gigante, estilo banco)
            const SizedBox(height: 20),
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
                color: activeColor, // Rojo o Verde se ven bien en ambos modos
              ),
              decoration: InputDecoration(
                hintText: "0.00",
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.3)),
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
            
            // --- SECCIÓN AI / CATEGORÍA ---
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
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    )
                  : (aiProvider.suggestedCategory.isNotEmpty ||
                          manualCategory != null) 
                      ? GestureDetector(
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
                              manualCategory = selectedManualCategory;
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              // Usamos opacidad para que el color de fondo no sea muy brillante en modo oscuro
                              color: manualCategory != null
                                  ? Colors.green.withOpacity(0.15)
                                  : colorScheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: manualCategory != null
                                    ? Colors.green.withOpacity(0.5)
                                    : colorScheme.primary.withOpacity(0.5),
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
                                      ? Colors.green
                                      : colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  manualCategory != null
                                      ? strings.selectCategoryText
                                      : "${strings.category}: ${aiProvider.suggestedCategory}",
                                  style: TextStyle(
                                    color: manualCategory != null
                                        ? Colors.green
                                        : colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: manualCategory != null
                                      ? Colors.green
                                      : colorScheme.primary,
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
                  // Usamos el Primary del tema (Azul/Indigo)
                  backgroundColor: colorScheme.primary, 
                  foregroundColor: colorScheme.onPrimary, // Texto blanco
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child:  Text(
                  strings.saveDeudaText,
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

  String _involucradoText(BuildContext context) {
    
    if (debo) {
      return AppLocalizations.of(context)!.quienMeDebeText;
    } else {
      return AppLocalizations.of(context)!.quienLeDeboText;
    }
  }

  // Helper para construir los botones del Toggle
  Widget _buildToggleOption(BuildContext context, String label, bool deboButton) {
    // Necesitamos el contexto para el tema
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
            // En modo activo: Color de superficie (blanco/gris oscuro). Inactivo: transparente
            color: isActive ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            // Sombra solo en modo claro
            boxShadow: (isActive && !isDark)
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                      ? AppColors.expense
                      : AppColors.income)
                  : colorScheme.onSurfaceVariant, // Color gris adaptable para inactivos
            ),
          ),
        ),
      ),
    );
  }
}