import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:money_move/screens/edit_deuda_screen.dart';
import 'package:money_move/screens/ver_deuda_screen.dart';
import 'package:money_move/utils/date_formater.dart';
import 'package:money_move/utils/ui_utils.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ListaDeudasWidget extends StatefulWidget {
  bool deboList;
  bool pagada;
  ListaDeudasWidget({super.key, this.deboList = true, required this.pagada});

  @override
  State<ListaDeudasWidget> createState() => _ListaDeudasWidget();
}

class _ListaDeudasWidget extends State<ListaDeudasWidget> {
  @override
  void initState() {
    super.initState();
    final userProv = Provider.of<UserProvider>(context, listen: false);
    Provider.of<DeudaProvider>(
      context,
      listen: false,
    ).initSubscription(userProv.usuarioActual);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeudaProvider>(context);
    final lista = provider.deudas
        .where((deuda) => deuda.debo == widget.deboList)
        .where((deuda) => deuda.pagada == widget.pagada)
        .toList();

    // Accedemos al esquema de colores actual
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
        final deuda = lista[index];
        return _buildDebtCard(context, deuda, provider);
      },
    );
  }

  Widget _buildDebtCard(
    BuildContext context,
    dynamic deuda,
    DeudaProvider provider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Definimos colores según si YO DEBO o ME DEBEN
    final bool soyDeudor = deuda.debo;

    final Color mainColor = soyDeudor
        ? AppColors
              .accent // Color naranja/rojo
        : AppColors.income; // Color verde

    // TRUCO PRO: En lugar de shade50 (que es blanco), usamos opacidad.
    // Esto funciona perfecto en Dark Mode porque se mezcla con el gris oscuro.
    final Color chipBgColor = mainColor.withValues(alpha: isDark ? 0.15 : 0.1);

    final strings = AppLocalizations.of(context)!;

    final String label = soyDeudor
        ? (!widget.pagada ? strings.payableText : strings.pagadoText)
        : (!widget.pagada ? strings.receivableText : strings.cobradoText);

    final IconData iconStatus = soyDeudor
        ? Icons.arrow_outward_rounded
        : Icons.arrow_downward_rounded;

    final double porcentajePagado = (deuda.monto > 0)
        ? (deuda.abono / deuda.monto)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        // Fondo adaptable
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        // Sombra solo en modo claro
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
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    // 1. FRANJA LATERAL DE COLOR
                    Container(width: 6, color: mainColor),

                    // 2. CONTENIDO PRINCIPAL
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 12, 16.0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Encabezado: Etiqueta y Menú
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Chip de estado
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !widget.pagada
                                        ? chipBgColor
                                        : AppColors.income.withValues(
                                            alpha: 0.15,
                                          ), // Color translúcido adaptable
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        iconStatus,
                                        size: 12,
                                        color: !widget.pagada
                                            ? mainColor
                                            : AppColors.income,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: !widget.pagada
                                              ? mainColor
                                              : AppColors.income,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Menú de opciones
                                _buildPopupMenu(
                                  context,
                                  deuda,
                                  provider,
                                  colorScheme,
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Información Principal
                            Row(
                              children: [
                                // AVATAR CON INICIAL
                                CircleAvatar(
                                  radius: 22,
                                  // Fondo del avatar basado en el tema (Primary Container)
                                  backgroundColor: widget.pagada
                                      ? AppColors.income
                                      : colorScheme.primaryContainer,
                                  child: Text(
                                    deuda.involucrado.isNotEmpty
                                        ? deuda.involucrado[0].toUpperCase()
                                        : "?",
                                    style: TextStyle(
                                      // Texto del avatar contrastante
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Textos centrales
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        deuda.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: colorScheme
                                              .onSurface, // Texto principal
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "${strings.withInvolucradoText}: ${deuda.involucrado}",
                                        style: TextStyle(
                                          color: colorScheme
                                              .onSurfaceVariant, // Texto secundario
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                                // MONTO
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "\$${deuda.monto.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color:
                                            mainColor, // Mantenemos el color semántico (rojo/verde)
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.event_busy_rounded,
                                          size: 12,
                                          color: colorScheme
                                              .outline, // Icono gris suave
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${strings.venceText}: ${formatDate(deuda.fechaLimite)}",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: porcentajePagado,
                  minHeight: 5,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                ),
              ),
            ],
          ),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VerDeuda(
              id: deuda.id,
              title: deuda.title,
              description: deuda.description,
              monto: deuda.monto,
              abono: deuda.abono,
              involucrado: deuda.involucrado,
              fechaLimite: deuda.fechaLimite,
              categoria: deuda.categoria,
              debo: deuda.debo,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(
    BuildContext context,
    dynamic deuda,
    DeudaProvider provider,
    ColorScheme colorScheme,
  ) {
    final strings = AppLocalizations.of(context)!;
    return SizedBox(
      height: 24,
      width: 24,
      child: PopupMenuButton(
        padding: EdgeInsets.zero,
        color: colorScheme.surfaceContainer, // Fondo del menú
        icon: Icon(
          Icons.more_vert,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) {
          if (value == "borrar") {
            UiUtils.showDeleteConfirmation(context, () {
              Provider.of<DeudaProvider>(
                context,
                listen: false,
              ).deleteDeuda(deuda.id);
            });
          }
          if (value == "editar") {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditDeudaScreen(deuda: deuda),
              ),
            );
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: "editar",
            child: Row(
              children: [
                Icon(Icons.edit, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  strings.editText,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: "borrar",
            child: Row(
              children: [
                const Icon(Icons.delete, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Text(strings.deleteText, style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    final strings = AppLocalizations.of(context)!;

    // Lógica para decidir el texto y el icono según si estamos viendo pagadas o pendientes
    String titulo;
    String subtitulo;
    IconData icono;

    if (widget.pagada) {
      // ESTADO VACÍO PARA HISTORIAL (PAGADAS)
      titulo = strings.noHistorialText;
      subtitulo = strings.noPaidDeudasText;
      icono = Icons.history_edu_rounded; // Icono de historial
    } else {
      // ESTADO VACÍO PARA PENDIENTES (LO QUE TIENES AHORA)
      titulo = strings.allAlrightDeudasText;
      subtitulo = strings.noOutstandingDeudas;
      icono = Icons.handshake_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 70, color: colorScheme.outline),
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
