import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';

// ignore: must_be_immutable
class AddAbonoWindow extends StatefulWidget {
  double monto;
  double abono;
  final bool debo;
  
  AddAbonoWindow({
    super.key,
    required this.monto,
    required this.abono,
    required this.debo,
  });

  @override
  State<AddAbonoWindow> createState() => _AddAbonoWindowState();
}

class _AddAbonoWindowState extends State<AddAbonoWindow> {
  // --- CORRECCIÓN 1: Mover el controller aquí arriba ---
  late TextEditingController montoController;
  // --- NUEVA VARIABLE: Para controlar el checkbox ---
  bool _autoTransaction = true;

  @override
  void initState() {
    super.initState();
    montoController = TextEditingController();
  }

  @override
  void dispose() {
    // Es importante liberar el controller cuando la ventana se cierra
    montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;
    
    // Color dinámico según si debes o te deben (puedes ajustarlo)
    final mainColor = widget.debo ? AppColors.accent : AppColors.income;

    return AlertDialog(
      insetPadding: const EdgeInsets.only(top: 20, bottom: 20, left: 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(1, 15, 1, 15),
            child: Text(
              strings.insertAmountPaymentText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          TextField(
            controller: montoController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            decoration: InputDecoration(
              hintText: "0.00",
              hintStyle: TextStyle(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
              prefixText: "\$ ",
              prefixStyle: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Text(
            "${(widget.debo ? strings.totalPorPagarText : strings.totalPorCobrarText)}: ${widget.monto - widget.abono}",
            style: TextStyle(color: colorScheme.outline),
          ),
          
          const SizedBox(height: 15),

          // --- NUEVO: Checkbox para automatizar la transacción ---
          GestureDetector(
            onTap: () {
              setState(() {
                _autoTransaction = !_autoTransaction;
              });
            },
            child: Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _autoTransaction,
                    activeColor: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _autoTransaction = val ?? true;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.generateAutoTransactionText, // Reemplaza con strings.autoTransactionText si lo agregas al l10n
                    style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),
          
          Row(
            children: [
              //----------Cancelar------------
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: colorScheme.surface),
                  label: Text(
                    strings.cancelText,
                    style: TextStyle(color: colorScheme.surface, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.expense,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              //----------Abonar------------
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final double? amount = double.tryParse(montoController.text);
                      Navigator.pop(context, (amount, _autoTransaction));
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
                      backgroundColor: colorScheme.primary,
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
        ],
      ),
    );
  }
}