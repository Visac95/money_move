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

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider()..loadTransactions(),
        ),
        ChangeNotifierProvider(create: (_) => AiCategoryProvider()),
        ChangeNotifierProvider(create: (_) => UiProvider()),
        ChangeNotifierProvider(create: (_) => DeudaProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          //title: AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: const [
            AppLocalizations.delegate, // Tu delegado generado
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales:
              AppLocalizations.supportedLocales, // Idiomas soportados
          // Esto permite que cambie solo según la configuración del celular
          themeMode: ThemeMode.system,

          // TEMA CLARO (Día)
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.lightBackground,
            // Definimos el esquema de colores semántico
            colorScheme: const ColorScheme.light(
              primary: AppColors.lightPrimary,
              secondary: AppColors
                  .income, // Usamos verde como secundario o el que prefieras
              surface: AppColors.lightSurface, // Color de las Tarjetas
              onSurface: AppColors
                  .lightTextPrimary, // Color de Texto sobre las tarjetas
              outline: AppColors
                  .lightTextSecondary, // Color para textos secundarios/iconos grises
              error: AppColors.expense,
            ),
            // Configuramos las tarjetas por defecto
            cardTheme: CardThemeData(
              color: AppColors.lightSurface,
              elevation: 0,
            ),
            // Iconos por defecto
            iconTheme: const IconThemeData(color: AppColors.lightIcon),
          ),

          // TEMA OSCURO (Noche)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.darkBackground,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.darkPrimary,
              secondary: AppColors.income,
              surface: AppColors.darkSurface, // Las tarjetas serán gris oscuro
              onSurface: AppColors.darkTextPrimary, // El texto será blanco
              outline: AppColors.darkTextSecondary,
              error: AppColors.expense,
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
