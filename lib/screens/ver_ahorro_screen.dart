import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/models/ahorro.dart';
import 'package:money_move/providers/ahorro_provider.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/screens/edit_ahorro_screen.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/utils/category_translater.dart';
import 'package:money_move/utils/mode_color_app_bar.dart';
import 'package:money_move/utils/ui_utils.dart';
import 'package:money_move/widgets/add_abono_window.dart';
import 'package:money_move/widgets/add_aporte_window.dart';
import '../utils/date_formater.dart';
import 'package:provider/provider.dart';

class VerAhorroScreen extends StatelessWidget {
  final String ahorroId;
  const VerAhorroScreen({super.key, required this.ahorroId});

  Future<double?> _mostrarDialogoAbono(
    BuildContext context,
    Ahorro ahorro,
  ) async {
    final double? montoIngresado = await showDialog<double>(
      context: context,
      builder: (context) => AddAporteWindow(
        monto: ahorro.monto,
        abono: ahorro.abono,
      ),
    );
    return montoIngresado;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = AppLocalizations.of(context)!;

    // Obtener el ahorro actualizado
    final ahorro = Provider.of<AhorroProvider>(context).getAhorroById(ahorroId);

    // Manejo de seguridad por si se borra y el widget sigue montado
    if (ahorro == null) return const SizedBox.shrink();

    final Color mainColor =
        AppColors.income; // Color verde/positivo para ahorros
    final double restante = ahorro.monto - ahorro.abono;
    final double porcentajePagado = (ahorro.monto > 0)
        ? (ahorro.abono / ahorro.monto)
        : 0.0;
    final isDark = theme.brightness == Brightness.dark;

    void caseNotiAbono(AbonoStatus status) {
      // (Misma lógica de notificaciones que tenías)
      final strings = AppLocalizations.of(context)!;
      Color color;
      String text;

      switch (status) {
        case AbonoStatus.exito:
          text = strings.abonoSucessText;
          color = Colors.green;
          break;
        case AbonoStatus.montoInvalido:
          text = strings.putAmountHigherZeroText;
          color = Colors.red;
          break;
        case AbonoStatus.excedeDeuda:
          text = strings.putAmountLowerText;
          color = Colors.orange;
          break;
        case AbonoStatus.error:
          text = strings.errorHasOccurredText;
          color = Colors.red;
          break;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          ahorro.title,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        centerTitle: true,
        backgroundColor: modeColorAppbar(context, 0.4),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Opción de editar movida arriba para limpiar la parte inferior
          IconButton(
            icon: Icon(Icons.edit_rounded, color: colorScheme.onSurface),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditAhorroScreen(ahorro: ahorro),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- 1. EL ENFOQUE EN LA META (EMOJI + TÍTULO) ---
              // Esto diferencia visualmente la deuda (dinero) del ahorro (meta)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: mainColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    ahorro.emoji.isEmpty ? "💰" : ahorro.emoji,
                    style: const TextStyle(fontSize: 45),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const SizedBox(height: 5),

              // El monto total aparece más sutil debajo del título
              Text(
                "${strings.goalText}: \$${ahorro.monto.toStringAsFixed(2)}",
                style: TextStyle(
                  color: colorScheme.outline,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),

              // --- 2. TARJETA DE PROGRESO REDISEÑADA ---
              _cardSavingsProgress(
                colorScheme,
                isDark,
                mainColor,
                ahorro,
                context,
                strings,
                porcentajePagado,
                restante,
              ),

              const SizedBox(height: 25),

              // --- 3. BOTONES DE ACCIÓN ---
              ahorro.ahorrado
                  ? _buildCompletedBadge(strings, colorScheme)
                  : _actionButtons(
                      strings,
                      context,
                      ahorro,
                      colorScheme,
                      caseNotiAbono,
                    ),

              const SizedBox(height: 20),

              // Botón eliminar (texto simple, menos intrusivo)
              TextButton.icon(
                onPressed: () {
                  UiUtils.showDeleteConfirmation(context, () {
                    Provider.of<AhorroProvider>(
                      context,
                      listen: false,
                    ).deleteAhorro(ahorro);
                    Navigator.pop(context);
                  });
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: colorScheme.error,
                  size: 20,
                ),
                label: Text(
                  strings.deleteText,
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Badge visual cuando se completa
  Widget _buildCompletedBadge(
    AppLocalizations strings,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.income.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.income),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified, color: AppColors.income, size: 30),
          const SizedBox(width: 10),
          Text(
            strings.objectiveCompletedText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // --- NUEVA TARJETA: Más enfocada en "Llenar la barra" ---
  Widget _cardSavingsProgress(
    ColorScheme colorScheme,
    bool isDark,
    Color mainColor,
    Ahorro ahorro,
    BuildContext context,
    AppLocalizations strings,
    double porcentajePagado,
    double restante,
  ) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(30), // Más redondeado
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Column(
        children: [
          // Fila superior: Categoría y Fecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chip de Categoría
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppConstants.getIconForCategory(ahorro.categoria),
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      getCategoryName(context, ahorro.categoria),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Fecha Meta
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatDate(ahorro.fechaMeta),
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 25),

          // --- EL NÚMERO GRANDE (LO AHORRADO) ---
          Text(
            "${strings.savedText}:",
            style: TextStyle(color: colorScheme.outline, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            "\$${ahorro.abono.toStringAsFixed(2)}",
            style: TextStyle(
              color: mainColor,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
            ),
          ),

          const SizedBox(height: 20),

          // --- BARRA DE PROGRESO GRUESA ---
          Stack(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 24,
                    width:
                        constraints.maxWidth * porcentajePagado.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [mainColor.withValues(alpha: 0.7), mainColor],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
              // Texto dentro de la barra si hay espacio
              Positioned.fill(
                child: Center(
                  child: Text(
                    "${(porcentajePagado * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      color: porcentajePagado > 0.5
                          ? Colors.white
                          : colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // --- Info Restante ---
          if (restante > 0)
            Text(
              "${strings.restanteText} \$${restante.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),

          // Descripción (si existe)
          if (ahorro.description.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              ahorro.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButtons(
    AppLocalizations strings,
    BuildContext context,
    Ahorro ahorro,
    ColorScheme colorScheme,
    void Function(AbonoStatus status) caseNotiAbono,
  ) {
    return Row(
      children: [
        // 1. Botón Grande: ABONAR (Es la acción principal en ahorros)
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () async {
                final double? monto = await _mostrarDialogoAbono(
                  context,
                  ahorro,
                );
                if (!context.mounted) return;

                if (monto != null) {
                  final status =
                      await Provider.of<AhorroProvider>(
                        context,
                        listen: false,
                      ).abonarAhorro(
                        ahorro,
                        monto,
                        Provider.of<TransactionProvider>(
                          context,
                          listen: false,
                        ),
                        context,
                      );

                  if (context.mounted) caseNotiAbono(status);
                }
              },
              icon: const Icon(Icons.savings_outlined, color: Colors.white),
              label: Text(
                strings.contributeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.income, // Verde fuerte
                elevation: 4,
                shadowColor: AppColors.income.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 15),

        // 2. Botón Pequeño: COMPLETAR (Solo si ya casi está listo o manual)
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 60,
            child: OutlinedButton(
              onPressed: () => _pagarAhorroTotalmente(context, ahorro),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Icon(Icons.check, color: colorScheme.onSurface),
            ),
          ),
        ),
      ],
    );
  }

  void _pagarAhorroTotalmente(BuildContext context, Ahorro ahorro) {
    // (Tu lógica original de pagar totalmente se mantiene igual)
    final strings = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.paidDeudasText),
        content: Text(strings.markAsPaidConfirmText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(strings.cancelText),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.income,
            ), // Verde para confirmar
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                if (!context.mounted) return;
                await Provider.of<AhorroProvider>(
                  context,
                  listen: false,
                ).terminarAhorro(
                  ahorro,
                  Provider.of<TransactionProvider>(context, listen: false),
                  context,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(strings.deudaPaidSucessText),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // error handle
              }
            },
            child: Text(strings.markAsPaidText),
          ),
        ],
      ),
    );
  }
}
