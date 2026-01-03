import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/providers/ui_provider.dart';
import 'package:provider/provider.dart';

class UltimasDeudas extends StatefulWidget {
  const UltimasDeudas({super.key});

  @override
  State<UltimasDeudas> createState() => _UltimasDeudasState();
}

class _UltimasDeudasState extends State<UltimasDeudas> {
  
  // Formateador de fecha simple
  String _formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    return "$day/$month"; // Solo mostramos día y mes para ahorrar espacio
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DeudaProvider>(context);
    // Tomamos solo las últimas 2 o 3 deudas para la vista previa
    final lista = provider.deudas; 

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha:0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        children: [
          // --- ENCABEZADO ---
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.lastDeudasText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.handshake_rounded, // Icono diferente a "history" para diferenciarlo
                  color: colorScheme.outline,
                  size: 20,
                ),
              ],
            ),
          ),

          // --- LISTA O EMPTY STATE ---
          lista.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, 
                           size: 40, color: colorScheme.tertiary), // Color distinto al de transacciones
                      const SizedBox(height: 8),
                      Text(
                        strings.noOutstandingDeudas,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  // Mostramos máximo 2 elementos en el widget del home
                  itemCount: lista.length > 2 ? 2 : lista.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final deuda = lista[index];
                    
                    // --- LÓGICA DE COLORES DE TU REFERENCIA ---
                    final bool soyDeudor = deuda.debo;
                    final Color statusColor = soyDeudor 
                        ? AppColors.accent // Rojo/Naranja
                        : AppColors.income; // Verde
                    
                    // Icono direccional
                    final IconData statusIcon = soyDeudor
                        ? Icons.arrow_outward_rounded // Sale dinero
                        : Icons.arrow_downward_rounded; // Entra dinero

                    return InkWell(
                      // Opcional: Si quieres que al tocar vaya al detalle, implementa onTap aquí
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                         // Aquí podrías navegar a editar deuda si quisieras
                      },
                      child: Row(
                        children: [
                          // 1. AVATAR CON INICIAL (Diferenciador clave de transacciones)
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              deuda.involucrado.isNotEmpty 
                                  ? deuda.involucrado[0].toUpperCase() 
                                  : "?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // 2. DATOS DE LA DEUDA
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deuda.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 12, color: colorScheme.outline),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        deuda.involucrado,
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // 3. MONTO Y ESTADO
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Icon(statusIcon, size: 14, color: statusColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    "\$${deuda.monto.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: statusColor, // Usamos el color semántico
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${strings.venceText}: ${_formatDate(deuda.fechaLimite)}",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.outline,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

          const SizedBox(height: 10),

          // --- BOTÓN VER TODAS ---
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Provider.of<UiProvider>(context, listen: false)
                  .selectedIndex = 2, // Cambiado a 2 asumiendo que "Deudas" es la 3ra pestaña
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.secondaryContainer.withValues(alpha:0.4),
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    strings.seeAllDeudasText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}