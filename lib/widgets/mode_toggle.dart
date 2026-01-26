import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/space_provider.dart'; // <--- CAMBIO IMPORTANTE
import 'package:provider/provider.dart';

class ModeToggle extends StatelessWidget {
  const ModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ahora escuchamos al SpaceProvider (el dueño de la verdad)
    final spaceProv = Provider.of<SpaceProvider>(context);
    final isShared = spaceProv.isSpaceMode;

    final strings = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        // 2. VALIDACIÓN UX:
        // Si intenta activar el modo compartido pero no está en un grupo...
        if (!isShared && !spaceProv.isInSpace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("No perteneces a ningún grupo"),
              backgroundColor: AppColors.expense,
            ),
          );
          return;
        }

        // 3. Ejecutamos el cambio en SpaceProvider
        spaceProv.setSpaceMode(!isShared);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isShared ? colorScheme.inversePrimary : colorScheme.primary,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isShared ? Colors.indigo.shade200 : Colors.teal.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption(
              context,
              title: strings.personalText,
              isActive: !isShared,
              activeColor: AppColors.brandPrimary,
              colorScheme: colorScheme,
              icon: Icons.person,
            ),
            _buildOption(
              context,
              title: strings.compartidoText,
              isActive: isShared,
              activeColor: AppColors.accent,
              colorScheme: colorScheme,
              icon: Icons.group,
            ),
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
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? activeColor : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? colorScheme.onSurface : Colors.grey.shade600,
          ),
          const SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              color: isActive ? colorScheme.onSurface : Colors.grey.shade600,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
