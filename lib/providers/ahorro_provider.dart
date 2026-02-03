import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/ahorro.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/providers/deuda_provider.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/services/database_service.dart';

class AhorroProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  User? _currentUser;
  String? _currentSpaceId;
  bool _isSpaceMode = false;

  List<Ahorro> _personalAhorros = [];
  List<Ahorro> _spaceAhorros = [];
  bool _isLoading = true;

  List<Ahorro> get ahorros => _isSpaceMode ? _spaceAhorros : _personalAhorros;
  bool get isLoading => _isLoading;

  StreamSubscription? _personalSub;
  StreamSubscription? _spaceSub;

  void updateFromExternal(User? user, String? spaceId, bool isSpaceMode) {
    // 1. Si nada importante cambió, no hacemos nada (Evita loops infinitos)
    if (_currentUser?.uid == user?.uid &&
        _currentSpaceId == spaceId &&
        _isSpaceMode == isSpaceMode) {
      return;
    }

    // 2. Actualizamos variables
    _currentUser = user;
    _currentSpaceId = spaceId;
    _isSpaceMode =
        isSpaceMode; // <--- Aquí recibimos el modo desde TransactionProvider

    // 3. Recargamos datos (Lógica simplificada tipo Eager Loading)
    _initAhorros(user, spaceId);
    print("💀🤐🫤☹️✅🐈‍⬛ $spaceId, ${user?.uid}");
  }

  void _initAhorros(User? user, String? linkedSpaceId) {
    if (user == null) return;
    print("🐈‍⬛11111DDDDDDD");
    _isLoading = true;
    notifyListeners();

    // A. Cancelar suscripciones viejas por si acaso
    _personalSub?.cancel();
    _spaceSub?.cancel();

    // B. Escuchar Transacciones PERSONALES (Siempre)
    print("🐈‍⬛2222222DDDDDD");
    _personalSub = _dbService.getAhorrosStream(user.uid, null, false).listen((
      data,
    ) {
      _personalAhorros = data;
      _personalAhorros.sort(
        (a, b) => b.fechaMeta.compareTo(a.fechaMeta),
      ); // Ordenar por fecha
      print("🐈‍⬛333333333DDDDDDD");

      if (!_isSpaceMode) _isLoading = false;
      notifyListeners();
      print("🐈‍⬛4444444444444DDDDDDD");
    });
    print("🐈‍⬛5555555555555DDDDD");
    if (linkedSpaceId != null) {
      _spaceSub = _dbService
          .getAhorrosStream(user.uid, linkedSpaceId, true) // true = es space
          .listen((data) {
            _spaceAhorros = data;
            _spaceAhorros.sort((a, b) => b.fechaMeta.compareTo(a.fechaMeta));

            // Si arrancamos en modo space, quitamos el loading aquí
            _isLoading = false;
            notifyListeners();
            print("🐈‍⬛66666666666666DDDDD");
          });
    } else {
      // Si no tiene space, aseguramos que la lista esté vacía
      _spaceAhorros = [];
      _isLoading = false; // Por si acaso
      print("🐈‍⬛777777777777DDDDDD");
    }
    print("🐈‍⬛888888888888888DDD");
  }

  // 2. AGREGAR DEUDA
  Future<void> addAhorro(
    Ahorro a,
  ) async {
    print("😶‍🌫️😶‍🌫️😶‍🌫️ 5");
    // A. Guardar en Firebase
    await _dbService.addAhorro(a, _isSpaceMode);
  }

  // 3. BORRAR
  Future<void> deleteAhorro(Ahorro a) async {
    await _dbService.deleteAhorro(a, _isSpaceMode);
  }

  // 4. ACTUALIZAR (Básico)
  Future<void> updateAhorro(Ahorro updatedAhorro) async {
    await _dbService.updateAhorro(updatedAhorro, _isSpaceMode);
  }

  // 5. PAGAR DEUDA COMPLETA
  Future<void> terminarAhorro(
    Ahorro a,
    TransactionProvider transProvider,
    BuildContext context,
  ) async {
    try {
      // Calculamos cuánto faltaba
      final montoRestante = a.monto - a.abono;

      // Creamos la transacción de pago
      await transProvider.addTransaction(
        Transaction(
          userId: FirebaseAuth.instance.currentUser!.uid,
          title: "${AppLocalizations.of(context)!.pagoDeText} ${a.title}",
          description: a.description,
          monto: montoRestante,
          saldo: transProvider.saldoActual,
          fecha: DateTime.now(),
          categoria: AppConstants.catSavings,
          isExpense: true, // Si yo debía, pagar es un Gasto.
        ),
      );

      // Actualizamos la deuda a PAGADA
      a.ahorrado = true;
      a.abono = a.monto;

      // Guardamos en Firebase
      await updateAhorro(a);
    } catch (_) {
      //print("Error al pagar deuda: $e");
    }
  }

  // 6. ABONAR A DEUDA
  Future<AbonoStatus> abonarAhorro(
    Ahorro a,
    double monto,
    TransactionProvider provider,
    BuildContext context,
  ) async {
    if (monto <= 0) return AbonoStatus.montoInvalido;

    // Pequeño margen de error para comparaciones de punto flotante
    if (monto > (a.monto - a.abono + 0.01)) return AbonoStatus.excedeDeuda;

    try {
      a.abono += monto;
      // Verificamos si ya se pagó completa
      if (a.abono >= a.monto - 0.01) {
        a.abono = a.monto; // Ajuste exacto
        a.ahorrado = true;
      }

      // Generamos la transacción del abono
      await provider.addTransaction(
        Transaction(
          userId: a.userId,
          title:
              "${(a.ahorrado ? AppLocalizations.of(context)!.pagoDeText : AppLocalizations.of(context)!.abonoForText)} ${a.title}",
          description: a.description,
          monto: monto,
          saldo: provider.saldoActual,
          fecha: DateTime.now(),
          categoria: AppConstants.catDebt,
          isExpense: true,
          deudaAsociada: a.id,
        ),
      );

      // Actualizamos en Firebase
      await updateAhorro(a);

      return AbonoStatus.exito;
    } catch (e) {
      return AbonoStatus.error;
    }
  }

  // --- FILTROS (Ahora síncronos porque los datos ya están en memoria) ---

  Ahorro? getAhorroById(String id) {
    try {
      return ahorros.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
