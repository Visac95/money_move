import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/models/deuda.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/screens/edit_deuda_screen.dart'; // Asumo que tienes o crearás esta pantalla
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/utils/ui_utils.dart';
import '../utils/date_formater.dart';
import 'package:provider/provider.dart';

class VerDeuda extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final double monto;
  final String involucrado;
  final DateTime fechaLimite;
  final String categoria;
  final bool debo;

  const VerDeuda({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.monto,
    required this.involucrado,
    required this.fechaLimite,
    required this.categoria,
    required this.debo,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Obtener la deuda actualizada del Provider
    final provider = Provider.of<DeudaProvider>(context);
    Deuda? deuda = provider.getDeudaById(id);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppLocalizations.of(context)!;

    if (deuda == null) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context)!.transactionNotExist), // O un texto genérico de error
        ),
      );
    }

    // 2. Lógica de colores (Igual que en transacciones pero adaptado a Deuda)
    // Si YO DEBO (true) -> Rojo/Naranja. Si ME DEBEN (false) -> Verde.
    final Color mainColor = deuda.debo
        ? AppColors.accent // Deuda negativa (tengo que pagar)
        : AppColors.income; // Deuda positiva (voy a recibir)

    // Cálculos para el progreso
    final double restante = deuda.monto - deuda.abono;
    final double porcentajePagado = (deuda.monto > 0) ? (deuda.abono / deuda.monto) : 0.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.transactionDetailsTitle, // O "Detalles de Deuda" si tienes esa key
          style: TextStyle(color: colorScheme.onSurface),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // --- 1. EL HÉROE (Monto Restante o Total) ---
              // En deudas, suele ser más útil ver cuánto falta, pero para consistencia
              // con el Home, mostramos el total y abajo el desglose.
              Hero(
                tag: deuda.id,
                child: Text(
                  "\$${deuda.monto.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
              
              // Estado / Subtítulo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    deuda.debo ? Icons.arrow_outward_rounded : Icons.arrow_downward_rounded,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    deuda.debo
                        ? "${strings.payableText} ${strings.toText}" // "Pagar a"
                        : "${strings.receivableText} ${strings.fromText}", // "Cobrar de"
                    style: TextStyle(
                      color: colorScheme.outline,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              // Nombre del Involucrado (Grande y claro)
              Text(
                deuda.involucrado,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // --- 2. TARJETA DE PROGRESO Y DETALLES ---
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onSurface.withOpacity(0.05), // Sombra muy sutil adaptativa
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Categoría
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            AppConstants.getIconForCategory(deuda.categoria),
                            size: 30,
                            color: mainColor,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.category,
                              style: TextStyle(
                                color: colorScheme.outline,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              deuda.categoria,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Chip de estado (Pagada o Pendiente)
                        if (deuda.pagada)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green),
                            ),
                            child:  Text(
                              strings.pagadaText, // Puedes usar localizations aquí
                              style: TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.green
                              ),
                            ),
                          )
                      ],
                    ),

                    const SizedBox(height: 25),

                    // BARRA DE PROGRESO (Exclusivo para Deudas)
                    // Muestra visualmente cuánto se ha abonado
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              strings.progressText, // Usar localization
                              style: TextStyle(fontSize: 12, color: colorScheme.outline),
                            ),
                            Text(
                              "${(porcentajePagado * 100).toStringAsFixed(0)}%",
                              style: TextStyle(
                                fontSize: 12, 
                                fontWeight: FontWeight.bold, 
                                color: mainColor
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: porcentajePagado,
                            minHeight: 10,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${strings.abonadoText} \$${deuda.abono.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                            ),
                            Text(
                              "${strings.restanteText} \$${restante.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),

                    // Detalles de texto
                    _buildDetailRow(
                      context,
                      AppLocalizations.of(context)!.titleText,
                      deuda.title,
                    ),
                    const SizedBox(height: 15),
                    
                    // Fecha Límite (Más importante que fecha inicio en deudas)
                    _buildDetailRow(
                      context,
                      AppLocalizations.of(context)!.venceText, // Asegúrate de tener esta key o usa "Vence"
                      formatDate(deuda.fechaLimite),
                    ),
                    
                    const SizedBox(height: 15),

                    // Descripción
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.descriptionText,
                            style: TextStyle(
                              color: colorScheme.outline,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            deuda.description.isEmpty
                                ? AppLocalizations.of(context)!.noDescription
                                : deuda.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // --- 3. BOTONES DE ACCIÓN ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      // Asegúrate de importar EditDeudaScreen
                      builder: (context) => EditDeudaScreen(deuda: deuda), 
                    ),
                  ),
                  icon: Icon(Icons.edit_rounded, color: colorScheme.surface),
                  label: Text(
                    AppLocalizations.of(context)!.editText, // "Editar"
                    style: TextStyle(color: colorScheme.surface, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: TextButton.icon(
                  onPressed: () {
                    UiUtils.showDeleteConfirmation(context, () {
                      Provider.of<DeudaProvider>(
                        context,
                        listen: false,
                      ).deleteDeuda(deuda.id);
                      // Cerrar la pantalla después de borrar
                      Navigator.pop(context); 
                    });
                  },
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  label: Text(
                    strings.deleteText, // "Eliminar"
                    style: TextStyle(color: colorScheme.error, fontSize: 16),
                  ),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: theme.colorScheme.outline, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}