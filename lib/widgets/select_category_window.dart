import 'package:flutter/material.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/l10n/app_localizations.dart';
// 1. IMPORTANTE: Importa tu helper de traducción
import 'package:money_move/utils/category_translater.dart'; 

class SelectCategoryWindow extends StatefulWidget {
  const SelectCategoryWindow({super.key});

  @override
  State<SelectCategoryWindow> createState() => _SelectCategoryWindowState();
}

class _SelectCategoryWindowState extends State<SelectCategoryWindow> {
  @override
  Widget build(BuildContext context) {
    // Accedemos al tema para colores adaptables
    final colorScheme = Theme.of(context).colorScheme;

    return SimpleDialog(
      title: Text(
        AppLocalizations.of(context)!.chooseCategoryManualTitle,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      // Color de fondo del diálogo adaptable
      backgroundColor: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      
      children: AppConstants.categories.map((categoryKey) {
        return SimpleDialogOption(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          onPressed: () {
            // 2. LÓGICA: Devolvemos la CLAVE (ej: cat_food)
            // Esto es correcto, la base de datos necesita la clave, no la traducción.
            Navigator.pop(context, categoryKey);
          },
          child: Row(
            children: [
              // Contenedor del ícono
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // 3. DISEÑO: Usamos colores del tema (PrimaryContainer)
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppConstants.getIconForCategory(categoryKey),
                  // Ícono en contraste (OnPrimaryContainer)
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // 4. UI: Mostramos la TRADUCCIÓN
              Expanded( // Expanded evita desbordamientos si el texto es largo
                child: Text(
                  // ¡AQUÍ ESTÁ LA MAGIA!
                  getCategoryName(context, categoryKey),
                  
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    // Texto adaptable (negro en light, blanco en dark)
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              
              // Opcional: Una flechita sutil para indicar selección
              Icon(Icons.chevron_right, color: colorScheme.outlineVariant, size: 18)
            ],
          ),
        );
      }).toList(),
    );
  }
}