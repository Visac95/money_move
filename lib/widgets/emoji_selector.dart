import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class EmojiSelector extends StatefulWidget {
  final String selectedEmoji;
  final Function(String) onEmojiSelected;

  const EmojiSelector({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
  });

  @override
  State<EmojiSelector> createState() => _EmojiSelectorState();
}

class _EmojiSelectorState extends State<EmojiSelector> {
  
  // Función para mostrar el teclado de emojis
  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Para ver esquinas redondeadas
      builder: (context) {
        return Container(
          height: 350, // Altura del teclado
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Pequeña barra superior para cerrar
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    // 1. Devolvemos el emoji seleccionado al padre
                    widget.onEmojiSelected(emoji.emoji);
                    // 2. Cerramos el modal
                    Navigator.pop(context);
                  },
                  config: Config(
                    height: 256,
                    checkPlatformCompatibility: true,
                    viewOrderConfig: const ViewOrderConfig(),
                    // Personalización de colores
                    emojiViewConfig: EmojiViewConfig(
                      backgroundColor: Theme.of(context).cardColor,
                      columns: 7,
                      emojiSizeMax: 28, // Tamaño del emoji
                    ),
                    categoryViewConfig: CategoryViewConfig(
                       indicatorColor: Theme.of(context).colorScheme.primary,
                       iconColorSelected: Theme.of(context).colorScheme.primary,
                       iconColor: Colors.grey,
                    )
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: GestureDetector(
        onTap: () => _showEmojiPicker(context),
        child: Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest, // Fondo suave
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: widget.selectedEmoji.isEmpty
                ? Icon(Icons.add_reaction_outlined, size: 30, color: colorScheme.primary)
                : Text(
                    widget.selectedEmoji,
                    style: const TextStyle(fontSize: 40),
                  ),
          ),
        ),
      ),
    );
  }
}