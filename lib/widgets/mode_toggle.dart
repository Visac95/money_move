import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/space_provider.dart';
import 'package:provider/provider.dart';

class ModeToggle extends StatelessWidget {
  final bool bigWidget;
  const ModeToggle({super.key, required this.bigWidget});

  @override
  Widget build(BuildContext context) {
    final spaceProv = Provider.of<SpaceProvider>(context);

    // 1. LÓGICA PRINCIPAL: Si no está en un Space, el widget no existe.
    if (!spaceProv.isInSpace) return const SizedBox();

    final isShared = spaceProv.isSpaceMode;
    final strings = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    // Color de borde/fondo activo según el modo
    final activeColor = isShared
        ? colorScheme.inversePrimary
        : colorScheme.primary;

    return GestureDetector(
      onTap: () {
        // Validación defensiva (por si acaso)
        if (!isShared && !spaceProv.isInSpace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.errorHasOccurredText),
              backgroundColor: AppColors.expense,
            ),
          );
          return;
        }
        spaceProv.setSpaceMode(!isShared);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          // Fondo suave translúcido
          color: activeColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: activeColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // -------------------------------------------------
            // OPCIÓN A: MODO GRANDE (Switch completo: Personal | Compartido)
            // -------------------------------------------------
            if (bigWidget) ...[
              _buildOption(
                context,
                title: strings.personalText,
                isActive: !isShared, // Activo si NO es compartido
                activeColor: AppColors
                    .brandPrimary, // O el color que prefieras para personal
                colorScheme: colorScheme,
                icon: Icons.person_rounded,
                showText: true,
              ),
              _buildOption(
                context,
                title: strings.compartidoText,
                isActive: isShared,
                activeColor: AppColors
                    .accent, // O el color que prefieras para compartido
                colorScheme: colorScheme,
                icon: Icons.group_rounded,
                showText: true,
              ),
            ]
            // -------------------------------------------------
            // OPCIÓN B: MODO PEQUEÑO (Solo icono actual + flechas)
            // -------------------------------------------------
            else ...[
              // Mostramos solo la opción ACTIVA para ahorrar espacio
              _buildOption(
                context,
                title: isShared ? strings.compartidoText : strings.personalText,
                isActive: true, // Siempre se ve "activo" el icono actual
                activeColor:
                    Colors.transparent, // Sin fondo interno en modo pequeño
                colorScheme: colorScheme,
                icon: isShared ? Icons.group_rounded : Icons.person_rounded,
                showText: false, // Sin texto
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.swap_horiz_rounded,
                color: colorScheme.surface,
                size: 18,
              ),
              const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String title,
    required bool isActive,
    required Color activeColor,
    required ColorScheme colorScheme,
    required IconData icon,
    required bool showText,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: showText ? 12 : 6,
        vertical: showText ? 6 : 2,
      ),
      decoration: BoxDecoration(
        // Si está activo, usamos el color de superficie (blanco/negro), si no, transparente
        color: isActive && showText ? colorScheme.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            // Si hay texto (grande) y está activo -> color del texto (primary/inverse)
            // Si no hay texto (pequeño) -> siempre color superficie (blanco sobre fondo oscuro)
            color: showText
                ? (isActive
                      ? activeColor
                      : colorScheme.surface.withOpacity(0.6))
                : colorScheme.surface,
            size: showText ? 20 : 18,
          ),

          if (showText) ...[
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isActive
                    ? activeColor
                    : colorScheme.surface.withOpacity(0.6),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
