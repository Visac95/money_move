import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/utils/category_translater.dart'; // Y esto

class CategoryFilterButton extends StatelessWidget {
  const CategoryFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    //final strings = AppLocalizations.of(context)!;
    final provider = Provider.of<TransactionProvider>(
      context,
    ); // Escucha cambios

    return PopupMenuButton<String>(
      // Icono y Texto que se ve ANTES de abrir el menú
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppConstants.getIconForCategory(provider.catFiltroActual),
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 6),
          // Limitamos el ancho del texto por si la categoría es muy larga
          Flexible(
            child: Text(
              getCategoryName(context, provider.catFiltroActual),
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 18, color: colorScheme.primary),
        ],
      ),

      onSelected: (value) {
        provider.cambiarCatFiltro(value);
      },

      // La lista de opciones
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _popupMenuItem(context, "all"),
        _popupMenuItem(context, "cat_food"),
        _popupMenuItem(context, "cat_transport"),
        _popupMenuItem(context, "cat_leisure"),
        _popupMenuItem(context, "cat_health"),
        _popupMenuItem(context, "cat_education"),
        _popupMenuItem(context, "cat_church"),
        _popupMenuItem(context, "cat_job"),
        _popupMenuItem(context, "cat_pet"),
        _popupMenuItem(context, "cat_home"),
        _popupMenuItem(context, "cat_services"),
        _popupMenuItem(context, "cat_debt"),
        _popupMenuItem(context, "cat_others"),
      ],
    );
  }

  // Método auxiliar privado para no repetir código en el menú
  PopupMenuItem<String> _popupMenuItem(BuildContext context, String category) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuItem<String>(
      value: category,
      child: Row(
        children: [
          Icon(
            AppConstants.getIconForCategory(category),
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Text(
            getCategoryName(context, category),
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
