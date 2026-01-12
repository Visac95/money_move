import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// --- TUS IMPORTS ---
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/providers/locale_provider.dart';
import 'package:money_move/providers/ui_provider.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/providers/settings_provider.dart'; // <--- 1. IMPORTA TU NUEVO ARCHIVO
import 'package:money_move/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

        // 2. AGREGA TU SETTINGS PROVIDER AQUÍ
        ChangeNotifierProvider(create: (_) => SettingsProvider()),

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
    // 3. USAMOS 'Consumer2' PARA ESCUCHAR IDIOMA (Locale) Y TEMA (Settings) A LA VEZ
    return Consumer2<LocaleProvider, SettingsProvider>(
      builder: (context, localeProv, settingsProv, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Money Move',

          // CONECTAMOS EL IDIOMA
          locale: localeProv.locale,

          onGenerateTitle: (context) =>
              AppLocalizations.of(context)?.appTitle ?? 'Money Move',

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,

          // 4. AQUÍ CONECTAMOS EL CAMBIO DE TEMA
          // Si settingsProv.isDarkMode es true, fuerza el tema oscuro.
          themeMode: settingsProv.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // TEMA CLARO
          theme: ThemeData(
            useMaterial3: true,
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
              surfaceContainer: AppColors.lightSurfaceContainer,
            ),
            cardTheme: const CardThemeData(
              color: AppColors.lightSurface,
              elevation: 0,
            ),
            iconTheme: const IconThemeData(color: AppColors.lightIcon),
          ),

          // TEMA OSCURO
          darkTheme: ThemeData(
            useMaterial3: true,
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
              surfaceContainer: AppColors.darkSurfaceContainer,
            ),
            cardTheme: const CardThemeData(
              color: AppColors.darkSurface,
              elevation: 0,
            ),
            iconTheme: const IconThemeData(color: AppColors.darkIcon),
          ),

          home: const MainScreen(),
        );
      },
    );
  }
}
