import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/space_provider.dart';
import 'package:money_move/utils/mode_color_app_bar.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AddAporteWindow extends StatefulWidget {
  final montoController = TextEditingController();
  double monto;
  double abono;
  AddAporteWindow({super.key, required this.monto, required this.abono});

  @override
  State<AddAporteWindow> createState() => _AddAporteWindowState();
}

class _AddAporteWindowState extends State<AddAporteWindow> {
  // 1. State variable for the checkbox (default true usually makes sense)
  bool _autoTransaction = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final montoController = widget.montoController;
    final strings = AppLocalizations.of(context)!;
    final spaceProv = Provider.of<SpaceProvider>(context, listen: false);
    final mainColor = (spaceProv.isInSpace && spaceProv.isSpaceMode)
        ? modeColorAppbar(context, 1)
        : colorScheme.primary;

    return AlertDialog(
      insetPadding: EdgeInsets.only(top: 20, bottom: 20, left: 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(1, 15, 1, 15),
            child: Text(
              strings.insertAmountContributeText,
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
              color: mainColor,
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
                color: mainColor,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),

          Text(
            "${(strings.restanteText)}: ${widget.monto - widget.abono}",
            style: TextStyle(color: colorScheme.outline),
          ),

          SizedBox(height: 15),

          // 2. CHECKBOX ROW
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
                SizedBox(width: 10),
                Text(
                  // You might want to add this string to your Localizations
                  "Create transaction automatically",
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          Row(
            children: [
              //----------Cancelar------------
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: AppColors.expense),
                  label: Text(
                    strings.cancelText,
                    style: TextStyle(color: AppColors.expense, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.expense.withValues(alpha: 0.1),
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
                    onPressed: () {
                      // Safety check for empty input
                      if (montoController.text.isEmpty) return;

                      final amount = double.tryParse(montoController.text);
                      if (amount == null) return;

                      // 3. RETURN THE RECORD (Double, Bool)
                      Navigator.pop(context, (amount, _autoTransaction));
                    },
                    icon: Icon(Icons.add_box, color: colorScheme.surface),
                    label: Text(
                      strings.contributeText,
                      style: TextStyle(
                        color: colorScheme.surface,
                        fontSize: 18,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
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
