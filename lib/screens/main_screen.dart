import 'package:flutter/material.dart';
// import 'package:money_move/config/app_colors.dart'; // Ya no se necesita
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/ui_provider.dart';
import 'package:money_move/screens/all_transactions_screen.dart';
import 'package:money_move/screens/all_deudas_screen.dart';
import 'package:money_move/screens/home_screen.dart';
import 'package:money_move/screens/settings_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Lista de pantallas
  final List<Widget> screens = const [
    HomeScreen(),
    AllTransactionsScreen(),
    AllDeudasScreen(),
    SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final int currentIndex = uiProvider.selectedIndex;
    
    final l10n = AppLocalizations.of(context)!;
    
    // Acceso al tema actual para los colores de la barra
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // 1. ELIMINADO: backgroundColor: AppColors.backgroundColor
      // El Scaffold tomará automáticamente el color definido en main.dart 
      // (Blanco humo en Light, Negro casi puro en Dark)

      body: IndexedStack(
        index: currentIndex, 
        children: screens
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          uiProvider.selectedIndex = index;
        },
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha:  0.6),
        type: BottomNavigationBarType.fixed,

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
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings), 
            label: l10n.navigationTextDeudas
          ),
        ],
      ),
    );
  }
}