import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';

class AddAbonoWindow extends StatefulWidget {
  const AddAbonoWindow({super.key});

  @override
  State<AddAbonoWindow> createState() => _AddAbonoWindowState();
}

class _AddAbonoWindowState extends State<AddAbonoWindow> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final montoController = TextEditingController();
    final strings = AppLocalizations.of(context)!;

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
              color: AppColors.accent,
            ),
            decoration: InputDecoration(
              hintText: "0.00",
              hintStyle: TextStyle(color: colorScheme.outline.withOpacity(0.3)),
              prefixText: "\$ ",
              prefixStyle: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
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

              //----------Cancelar------------
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
        ],
      ),
    );
  }
}
