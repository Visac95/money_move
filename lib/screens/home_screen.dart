import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/config/app_strings.dart';
import 'package:money_move/widgets/add_button.dart';
import 'package:money_move/widgets/balance_card.dart';
import 'package:money_move/widgets/ultimas_deudas.dart';
import 'package:money_move/widgets/ultimas_transacciones.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: Text(AppStrings.appTitle)),
      body: Column(
        children: [
          BalanceCard(),
          UltimasTransacciones(),
          UltimasDeudas(),

        ],
      
      ),
      floatingActionButton: AddButton(),
    );
  }
}
