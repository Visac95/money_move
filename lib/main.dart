import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:money_move/firebase_options.dart';
import 'package:money_move/providers/space_provider.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:money_move/services/auth_gate.dart';
import 'package:money_move/services/deep_link_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:money_move/config/app_colors.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/providers/locale_provider.dart';
import 'package:money_move/providers/ui_provider.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/providers/settings_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Captura errores de Flutter (pantalla roja) y los manda a Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // (Opcional) Captura errores asíncronos que no rompen la app pero son feos
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await initializeDateFormatting('es', null);

  final localeProvider = LocaleProvider();
  await localeProvider.fetchLocale();

  // Esto fuerza a Firestore a guardar datos en el disco del celular
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes:
        Settings.CACHE_SIZE_UNLIMITED, // Opcional: Para guardar mucha data
  );

  await DeepLinkService().initDeepLinks();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SpaceProvider()),
        ChangeNotifierProvider(create: (_) => AiCategoryProvider()),
        ChangeNotifierProvider(create: (_) => UiProvider()),
        ChangeNotifierProvider(create: (_) => DeudaProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProxyProvider<UserProvider, TransactionProvider>(
          // 1. Crea el provider vacío inicial
          create: (_) => TransactionProvider(),

          // 2. Cada vez que UserProvider cambie, se ejecuta esto:
          update: (context, userProv, transProv) {
            // Obtenemos el usuario de Firebase (puedes usar auth directly o userProv si lo tiene)
            final fbUser = FirebaseAuth.instance.currentUser;

            // Obtenemos el ID del space desde tu UserProvider (UserModel)
            // Asegúrate de que 'usuarioActual' sea accesible
            final spaceId = userProv.usuarioActual?.spaceId;

            // ¡Aquí ocurre la magia! Se llama solo.
            transProv!.init(fbUser, spaceId);

            return transProv;
          },
        ),
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
          navigatorKey: navigatorKey,
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
              inversePrimary: AppColors.lightInversePrimary,
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
              inversePrimary: AppColors.darkInversePrimary,
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

          home: const AuthGate(),
        );
      },
    );
  }
}
