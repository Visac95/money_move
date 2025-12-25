import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/ui_provider.dart';
import 'package:money_move/screens/all_transactions.dart';
import 'package:money_move/screens/all_deudas_screen.dart';
import 'package:money_move/screens/home_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Nota: Si tus pantallas son const, puedes dejar el const aquí, si no, así está bien.
  List<Widget> screens = [HomeScreen(), AllTransactions(), AllDeudasScreen()];

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final int currentIndex = uiProvider.selectedIndex;
    
    // Obtenemos las traducciones
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          uiProvider.selectedIndex = index;
        },
        // IMPORTANTE: Se eliminó 'const' aquí porque 'l10n' no es constante
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home), 
            label: l10n.navigationTextHome
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.monetization_on), 
            label: l10n.navigationTextTransactions
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long), 
            label: l10n.navigationTextDeudas
          ),
        ],
      ),
    );
  }
}