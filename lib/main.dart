import 'package:flutter/material.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/providers/locale_provider.dart';
import 'package:money_move/providers/ui_provider.dart';
import 'package:money_move/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import './providers/deuda_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. PREPARAMOS EL PROVIDER (Cargamos el idioma del disco)
  final localeProvider = LocaleProvider();
  await localeProvider.fetchLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider()..loadTransactions(),
        ),
        ChangeNotifierProvider(create: (_) => AiCategoryProvider()),
        ChangeNotifierProvider(create: (_) => UiProvider()),
        ChangeNotifierProvider(create: (_) => DeudaProvider()),
        
        // --- CORRECCIÓN AQUÍ ---
        // En lugar de 'create', usamos '.value' para pasar la instancia
        // que ya tiene el idioma cargado (localeProvider).
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para reconstruir TODA la app cuando cambie el idioma
    return Consumer<LocaleProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          
          // AQUÍ CONECTAMOS EL IDIOMA
          locale: provider.locale, 
          
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          
          themeMode: ThemeMode.system,

          // TEMA CLARO
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.lightBackground,
            colorScheme: const ColorScheme.light(
              primary: AppColors.lightPrimary,
              secondary: AppColors.income,
              surface: AppColors.lightSurface,
              onSurface: AppColors.lightTextPrimary,
              outline: AppColors.lightTextSecondary,
              error: AppColors.expense,
              outlineVariant: AppColors.lightOutlineVariant,
            ),
            cardTheme: CardThemeData(
              color: AppColors.lightSurface,
              elevation: 0,
            ),
            iconTheme: const IconThemeData(color: AppColors.lightIcon),
          ),

          // TEMA OSCURO
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.darkBackground,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.darkPrimary,
              secondary: AppColors.income,
              surface: AppColors.darkSurface,
              onSurface: AppColors.darkTextPrimary,
              outline: AppColors.darkTextSecondary,
              error: AppColors.expense,
              outlineVariant: AppColors.darkOutlineVariant,
            ),
            cardTheme: CardThemeData(
              color: AppColors.darkSurface,
              elevation: 0,
            ),
            iconTheme: const IconThemeData(color: AppColors.darkIcon),
          ),
          home: MainScreen(),
        );
      },
    );
  }
}