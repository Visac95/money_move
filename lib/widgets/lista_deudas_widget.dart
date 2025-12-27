import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/screens/edit_deuda_screen.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ListaDeudasWidget extends StatefulWidget {
  bool deboList;
  ListaDeudasWidget({super.key, this.deboList = true});

  @override
  State<ListaDeudasWidget> createState() => _ListaDeudasWidget();
}

class _ListaDeudasWidget extends State<ListaDeudasWidget> {
  @override
  void initState() {
    super.initState();
    Provider.of<DeudaProvider>(context, listen: false).loadDeudas();
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeudaProvider>(context);
    final lista = provider.deudas
        .where((deuda) => deuda.debo == widget.deboList)
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
        ? AppColors.accent // Color naranja/rojo
        : AppColors.income; // Color verde

    // TRUCO PRO: En lugar de shade50 (que es blanco), usamos opacidad.
    // Esto funciona perfecto en Dark Mode porque se mezcla con el gris oscuro.
    final Color chipBgColor = mainColor.withOpacity(isDark ? 0.15 : 0.1);

    final String label = soyDeudor ? "POR PAGAR" : "POR COBRAR";
    final IconData iconStatus = soyDeudor
        ? Icons.arrow_outward_rounded
        : Icons.arrow_downward_rounded;

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
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 1. FRANJA LATERAL DE COLOR
              Container(width: 6, color: mainColor),

              // 2. CONTENIDO PRINCIPAL
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                              color: chipBgColor, // Color translúcido adaptable
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(iconStatus, size: 12, color: mainColor),
                                const SizedBox(width: 4),
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Menú de opciones
                          _buildPopupMenu(context, deuda, provider, colorScheme),
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
                            backgroundColor: colorScheme.primaryContainer,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deuda.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: colorScheme.onSurface, // Texto principal
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "Con: ${deuda.involucrado}",
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant, // Texto secundario
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
                                  color: mainColor, // Mantenemos el color semántico (rojo/verde)
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_busy_rounded,
                                    size: 12,
                                    color: colorScheme.outline, // Icono gris suave
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Vence: ${_formatDate(deuda.fechaLimite)}",
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
                    ],
                  ),
                ),
              ),
            ],
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
    return SizedBox(
      height: 24,
      width: 24,
      child: PopupMenuButton(
        padding: EdgeInsets.zero,
        color: colorScheme.surfaceContainer, // Fondo del menú
        icon: Icon(Icons.more_vert, size: 20, color: colorScheme.onSurfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (value) {
          if (value == "borrar") {
            provider.deleteDeuda(deuda.id);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Deuda eliminada')));
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
                Text("Editar", style: TextStyle(color: colorScheme.onSurface)),
              ],
            ),
          ),
           PopupMenuItem(
            value: "borrar",
            child: Row(
              children: [
                const Icon(Icons.delete, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                const Text("Borrar", style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.handshake_outlined,
            size: 70,
            // Usamos un color que se vea bien en fondo oscuro y claro (outline o surfaceVariant)
            color: colorScheme.surfaceContainerHighest, 
          ),
          const SizedBox(height: 16),
          Text(
            "Todo saldado 🎉",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No tienes deudas pendientes",
            style: TextStyle(
              color: colorScheme.onSurfaceVariant, 
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}