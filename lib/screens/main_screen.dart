import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
// import 'package:money_move/config/app_colors.dart'; // Ya no se necesita
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/providers/ui_provider.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:money_move/screens/all_transactions_screen.dart';
import 'package:money_move/screens/all_deudas_screen.dart';
import 'package:money_move/screens/home_screen.dart';
import 'package:money_move/screens/settings_screen.dart';
import 'package:money_move/screens/stadistic_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static bool _avisoOfflineMostradoEnEstaSesion = false;
  @override
  void initState() {
    super.initState();
    _verificarConexionYMostrarAlerta();

    // ESTO ES EL INTERRUPTOR DE ENCENDIDO 👇
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. Encendemos Transacciones
      final userProv = Provider.of<UserProvider>(context, listen: false);
      userProv.initSubscription();

      final txProv = Provider.of<TransactionProvider>(context, listen: false);
      txProv.initSubscription(userProv.usuarioActual);

      // 2. Encendemos Deudas (de paso)
      final deudaProv = Provider.of<DeudaProvider>(context, listen: false);
      deudaProv.initSubscription(userProv.usuarioActual);
    });
  }

  Future<void> _verificarConexionYMostrarAlerta() async {
    // 1. Si ya lo mostramos en esta sesión, no hacemos nada.
    if (_avisoOfflineMostradoEnEstaSesion) return;

    // 2. Verificamos si hay internet
    final connectivityResult = await Connectivity().checkConnectivity();
    bool sinInternet = connectivityResult.contains(ConnectivityResult.none);

    if (sinInternet) {
      // 3. Verificamos si el usuario marcó "No volver a mostrar" en el pasado
      final prefs = await SharedPreferences.getInstance();
      bool ocultarAviso = prefs.getBool('ocultar_aviso_offline') ?? false;

      if (!ocultarAviso && mounted) {
        // Marcamos que ya se mostró en esta sesión
        _avisoOfflineMostradoEnEstaSesion = true;

        // 4. Mostramos el diálogo
        _mostrarDialogoOffline(context);
      }
    }
  }

  void _mostrarDialogoOffline(BuildContext context) {
    bool noVolverAMostrar = false;
    final strings = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) {
        // StatefulBuilder para que el checkbox funcione dentro del diálogo
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.cloud_off_rounded, color: Colors.orange),
                  SizedBox(width: 10),
                  Text(strings.noConectionModeText),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.noConectionModeDescriptionText,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Checkbox(
                        value: noVolverAMostrar,
                        onChanged: (val) {
                          setState(() {
                            noVolverAMostrar = val ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              noVolverAMostrar = !noVolverAMostrar;
                            });
                          },
                          child: Text(
                            strings.noShowAgainText,
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (noVolverAMostrar) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('ocultar_aviso_offline', true);
                    }
                    if (context.mounted) Navigator.of(ctx).pop();
                  },
                  child: Text(strings.gotItText),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Lista de pantallas
  final List<Widget> screens = const [
    HomeScreen(),
    AllTransactionsScreen(),
    StadisticScreen(),
    AllDeudasScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UiProvider>(context);
    final int currentIndex = uiProvider.selectedIndex;

    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          uiProvider.selectedIndex = index;
        },
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,

        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.navigationTextHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.monetization_on),
            label: l10n.navigationTextTransactions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: l10n.stadisticText,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: l10n.navigationTextDeudas,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settingsTitle,
          ),
        ],
      ),
    );
  }
}
