import 'package:flutter/material.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/config/app_strings.dart';

class SelectCategoryWindow extends StatefulWidget {
  const SelectCategoryWindow({super.key});

  @override
  State<SelectCategoryWindow> createState() => _SelectCategoryWindowState();
}

class _SelectCategoryWindowState extends State<SelectCategoryWindow> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppStrings.chooseCategoryManualTitle),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      children: AppConstants.categories.map((categoryItem) {
        return SimpleDialogOption(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          onPressed: () {
            Navigator.pop(context, categoryItem);
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  AppConstants.getIconForCategory(categoryItem),
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                categoryItem,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
