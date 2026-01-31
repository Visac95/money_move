import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/ahorro.dart'; // Asegúrate de tener este archivo
import 'package:money_move/providers/ahorro_provider.dart'; // Asegúrate de crear este provider
import 'package:money_move/utils/date_formater.dart';
import 'package:money_move/utils/ui_utils.dart';
import 'package:provider/provider.dart';

// Placeholder para las pantallas de edición/ver (créalas o ajusta los imports)
// import 'package:money_move/screens/edit_ahorro_screen.dart';
// import 'package:money_move/screens/ver_ahorro_screen.dart';

class ListaAhorrosWidget extends StatefulWidget {
  final bool completado; // En lugar de "pagada", usamos "completado"
  const ListaAhorrosWidget({super.key, required this.completado});

  @override
  State<ListaAhorrosWidget> createState() => _ListaAhorrosWidgetState();
}

class _ListaAhorrosWidgetState extends State<ListaAhorrosWidget> {
  @override
  Widget build(BuildContext context) {
    // Asumimos que tienes un AhorroProvider similar al ahorroProvider
    final provider = Provider.of<AhorroProvider>(context);

    final lista = provider.ahorros
        .where((ahorro) => ahorro.ahorrado == widget.completado)
        .toList();

    final colorScheme = Theme.of(context).colorScheme;

    if (lista.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: _buildEmptyState(colorScheme),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      itemCount: lista.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final ahorro = lista[index];
        return _buildSavingsCard(context, ahorro, provider);
      },
    );
  }

  Widget _buildSavingsCard(
    BuildContext context,
    Ahorro ahorro,
    AhorroProvider provider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Lógica de colores para Ahorros
    // Activo: Azul/Terciario (Crecimiento/Calma)
    // Completado: Verde (Éxito)
    final Color mainColor = widget.completado
        ? AppColors
              .income // Verde éxito
        : colorScheme.tertiary; // O usa Colors.blueAccent

    // Fondo del chip con opacidad
    final Color chipBgColor = mainColor.withValues(alpha: isDark ? 0.15 : 0.1);

    //final strings = AppLocalizations.of(context)!;

    // Cálculos matemáticos
    final double porcentaje = (ahorro.monto > 0)
        ? (ahorro.abono / ahorro.monto).clamp(0.0, 1.0)
        : 0.0;

    final int porcentajeTexto = (porcentaje * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navegación a ver detalle
          // Navigator.of(context).push(MaterialPageRoute(builder: (_) => VerAhorro(ahorroId: ahorro.id)));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    // 1. FRANJA LATERAL (Progreso visual)
                    Container(width: 6, color: mainColor),

                    // 2. CONTENIDO
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 12, 16.0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Encabezado: Categoría y Menú
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Chip de Categoría
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: chipBgColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    ahorro.categoria.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: mainColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                // Menú
                                _buildPopupMenu(
                                  context,
                                  ahorro,
                                  provider,
                                  colorScheme,
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Información Principal
                            Row(
                              children: [
                                // EMOJI HERO (Avatar)
                                Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: mainColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      ahorro.emoji.isNotEmpty
                                          ? ahorro.emoji
                                          : "🐷",
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Título y Meta
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ahorro.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: colorScheme.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            widget.completado
                                                ? Icons
                                                      .check_circle_outline_rounded
                                                : Icons.flag_rounded,
                                            size: 13,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.completado
                                                ? "¡Meta alcanzada!"
                                                : "Meta: ${formatDate(ahorro.fechaMeta)}",
                                            style: TextStyle(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Montos (Derecha)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "\$${ahorro.abono.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: mainColor,
                                      ),
                                    ),
                                    Text(
                                      "de \$${ahorro.monto.toStringAsFixed(0)}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // BARRA DE PROGRESO INFERIOR
              Padding(
                padding: const EdgeInsets.only(
                  left: 6,
                ), // Offset por la franja lateral
                child: Stack(
                  children: [
                    // Fondo de la barra
                    Container(
                      height: 6,
                      width: double.infinity,
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    // Progreso
                    FractionallySizedBox(
                      widthFactor: porcentaje,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Texto de porcentaje pequeño debajo de la barra (Opcional, estilo "badge")
              if (!widget.completado)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 16, 8),
                    child: Text(
                      "$porcentajeTexto%",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(
    BuildContext context,
    Ahorro ahorro,
    AhorroProvider provider,
    ColorScheme colorScheme,
  ) {
    final strings = AppLocalizations.of(context)!;
    return SizedBox(
      height: 24,
      width: 24,
      child: PopupMenuButton(
        padding: EdgeInsets.zero,
        color: colorScheme.surfaceContainer,
        icon: Icon(
          Icons.more_vert,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) {
          if (value == "borrar") {
            UiUtils.showDeleteConfirmation(context, () {
              provider.deleteAhorro(ahorro); // Asumiendo método delete
            });
          }
          if (value == "editar") {
            // Navigator.of(context).push(...)
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: "editar",
            child: Row(
              children: [
                Icon(Icons.edit, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(strings.editText),
              ],
            ),
          ),
          PopupMenuItem(
            value: "borrar",
            child: Row(
              children: [
                const Icon(Icons.delete, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Text(
                  strings.deleteText,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    //final strings = AppLocalizations.of(context)!;

    final String titulo = widget.completado
        ? "Sin metas cumplidas"
        : "No tienes ahorros";

    final String subtitulo = widget.completado
        ? "¡Tus éxitos financieros aparecerán aquí!"
        : "Comienza a guardar para tus sueños hoy.";

    final IconData icono = widget.completado
        ? Icons.emoji_events_outlined
        : Icons.savings_outlined;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icono,
            size: 70,
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitulo,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
