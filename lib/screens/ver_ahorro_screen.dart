import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/models/deuda.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/screens/edit_deuda_screen.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/utils/category_translater.dart';
import 'package:money_move/utils/mode_color_app_bar.dart';
import 'package:money_move/utils/ui_utils.dart';
import 'package:money_move/widgets/add_abono_window.dart';
import '../utils/date_formater.dart';
import 'package:provider/provider.dart';

class VerAhorroScreen extends StatelessWidget {
  final String deudaId;
  const VerAhorroScreen({super.key, required this.deudaId});

  // --- CORRECCIÓN 1: Ahora pedimos la 'deudaActual' como parámetro ---
  Future<double?> _mostrarDialogoAbono(
    BuildContext context,
    Deuda deudaActual,
  ) async {
    final double? montoIngresado = await showDialog<double>(
      context: context,
      builder: (context) => AddAbonoWindow(
        debo: deudaActual.debo, // Usamos datos frescos
        monto: deudaActual.monto, // Usamos datos frescos
        abono: deudaActual.abono, // Usamos datos frescos
      ),
    );
    return montoIngresado;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppLocalizations.of(context)!;
    final deuda = Provider.of<DeudaProvider>(context).getDeudaById(deudaId)!;
    final Color mainColor = deuda.debo ? AppColors.accent : AppColors.income;

    final double restante = deuda.monto - deuda.abono;
    final double porcentajePagado = (deuda.monto > 0)
        ? (deuda.abono / deuda.monto)
        : 0.0;
    final isDark = theme.brightness == Brightness.dark;

    void caseNotiAbono(AbonoStatus status) {
      final strings = AppLocalizations.of(context)!;
      switch (status) {
        case AbonoStatus.exito:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.abonoSucessText),
              backgroundColor: Colors.green,
            ),
          );
          break;
        case AbonoStatus.montoInvalido:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.putAmountHigherZeroText),
              backgroundColor: Colors.red,
            ),
          );
          break;
        case AbonoStatus.excedeDeuda:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.putAmountLowerText),
              backgroundColor: Colors.orange,
            ),
          );
          break;
        case AbonoStatus.error:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.errorHasOccurredText),
              backgroundColor: Colors.red,
            ),
          );
          break;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.deudaDetailsTitle,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        centerTitle: true,
        backgroundColor: modeColorAppbar(context, 0.4),
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

              // --- 1. EL HÉROE ---
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
                    deuda.debo
                        ? Icons.arrow_outward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    deuda.debo
                        ? "${strings.payableText} ${strings.toText}"
                        : "${strings.receivableText} ${strings.fromText}",
                    style: TextStyle(
                      color: colorScheme.outline,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Nombre del Involucrado
              Text(
                deuda.involucrado,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // --- 2. TARJETA DE PROGRESO ---
              _cardConteiner(
                colorScheme,
                isDark,
                mainColor,
                deuda,
                context,
                strings,
                porcentajePagado,
                restante,
              ),

              const SizedBox(height: 20),

              // --- 3. BOTONES DE ACCIÓN ---
              deuda.pagada
                  ? const SizedBox(height: 1)
                  : _actionButtons(
                      strings,
                      context,
                      deuda,
                      colorScheme,
                      caseNotiAbono,
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
                      ).deleteDeuda(deuda);
                      Navigator.pop(context);
                    });
                  },
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  label: Text(
                    strings.deleteText,
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

  Column _actionButtons(
    AppLocalizations strings,
    BuildContext context,
    Deuda deuda, // <--- Esta es la deuda actualizada que viene del build
    ColorScheme colorScheme,
    void Function(AbonoStatus status) caseNotiAbono,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                //------Pagar--------
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _pagarDeudaTotalmente(context, deuda);
                    },
                    icon: Icon(
                      Icons.check_circle_outline,
                      color: colorScheme.surface,
                    ),
                    label: Text(
                      strings.pagadoText,
                      style: TextStyle(
                        color: colorScheme.surface,
                        fontSize: 18,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.income,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              //------Abonar--------
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // --- CORRECCIÓN 2: Pasamos la 'deuda' actualizada a la función ---
                      final double? monto = await _mostrarDialogoAbono(
                        context,
                        deuda,
                      );
                      if (!context.mounted) return;
                      if (monto != null && context.mounted) {
                        final status =
                            await Provider.of<DeudaProvider>(
                              context,
                              listen: false,
                            ).abonarDeuda(
                              deuda,
                              monto,
                              Provider.of<TransactionProvider>(
                                context,
                                listen: false,
                              ),
                              context,
                            );

                        if (!context.mounted) return;
                        caseNotiAbono(status);
                      }
                    },
                    icon: Icon(Icons.add_box, color: colorScheme.surface),
                    label: Text(
                      strings.abonarText,
                      style: TextStyle(
                        color: colorScheme.surface,
                        fontSize: 18,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        //------Edit Button---------
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditDeudaScreen(deuda: deuda),
              ),
            ),
            icon: Icon(Icons.edit_rounded, color: colorScheme.surface),
            label: Text(
              strings.editText,
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
      ],
    );
  }

  Container _cardConteiner(
    ColorScheme colorScheme,
    bool isDark,
    Color mainColor,
    Deuda deuda,
    BuildContext context,
    AppLocalizations strings,
    double porcentajePagado,
    double restante,
  ) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
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
                  color: mainColor.withValues(alpha: 0.1),
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
                    style: TextStyle(color: colorScheme.outline, fontSize: 12),
                  ),
                  Text(
                    getCategoryName(context, deuda.categoria),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    strings.pagadaText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 25),

          // BARRA DE PROGRESO
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.progressText,
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  ),
                  Text(
                    "${(porcentajePagado * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
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
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    "${strings.restanteText} \$${restante.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // Detalles de texto
          _buildDetailRow(context, strings.titleText, deuda.title),
          const SizedBox(height: 15),

          // Fecha Límite
          _buildDetailRow(
            context,
            strings.venceText,
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
                  style: TextStyle(color: colorScheme.outline, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  deuda.description.isEmpty
                      ? AppLocalizations.of(context)!.noDescription
                      : deuda.description,
                  style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
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
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  void _pagarDeudaTotalmente(BuildContext context, Deuda deuda) {
    final strings = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.paidDeudasText),
        content: Text(strings.markAsPaidConfirmText),
        actions: [
          // Botón Cancelar
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Cierra solo el diálogo
            child: Text(strings.cancelText),
          ),

          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () async {
              Navigator.of(ctx).pop();

              try {
                if (!context.mounted) return;
                await Provider.of<DeudaProvider>(
                  context,
                  listen: false,
                ).pagarDeuda(
                  deuda,
                  Provider.of<TransactionProvider>(context, listen: false),
                  context,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(strings.deudaPaidSucessText),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                return;
              }
            },
            child: Text(strings.markAsPaidText),
          ),
        ],
      ),
    );
  }
}
