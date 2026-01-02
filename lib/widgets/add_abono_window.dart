import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';

// ignore: must_be_immutable
class AddAbonoWindow extends StatefulWidget {
  double monto;
  double abono;
  final bool debo;
  AddAbonoWindow({super.key, required this.monto, required this.abono, required this.debo});

  @override
  State<AddAbonoWindow> createState() => _AddAbonoWindowState();
}

class _AddAbonoWindowState extends State<AddAbonoWindow> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final montoController = TextEditingController();
    final strings = AppLocalizations.of(context)!;
    final double restante = widget.monto - widget.abono;

    return AlertDialog(
      insetPadding: EdgeInsets.only(top: 20, bottom: 20, left: 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(1, 15, 1, 15),
            child: Text(
              strings.insertAmountPaymentText,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              hintStyle: TextStyle(color: colorScheme.outline.withOpacity(0.3)),
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
          SizedBox(height: 15),
          Row(
            children: [
              //----------Cancelar------------
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.add_box, color: colorScheme.surface),
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

              SizedBox(width: 10),

              //----------Abonar------------
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(
                      context,
                      double.parse(montoController.text),
                    ),
                    icon: Icon(Icons.add_box, color: colorScheme.surface),
                    label: Text(
                      strings.abonar,
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
