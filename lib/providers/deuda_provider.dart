import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/deuda.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/services/database_service.dart';

class DeudaProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  User? _currentUser;
  String? _currentSpaceId;
  bool _isSpaceMode = false;

  List<Deuda> _personalDeudas = [];
  List<Deuda> _spaceDeudas = [];
  bool _isLoading = true;

  List<Deuda> get deudas => _isSpaceMode ? _spaceDeudas : _personalDeudas;
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
    _initDeudas(user, spaceId);
    print("💀🤐🫤☹️✅🐈‍⬛ $spaceId, ${user?.uid}");
  }

  void _initDeudas(User? user, String? linkedSpaceId) {
    if (user == null) return;
    print("🐈‍⬛11111DDDDDDD");
    _isLoading = true;
    notifyListeners();

    // A. Cancelar suscripciones viejas por si acaso
    _personalSub?.cancel();
    _spaceSub?.cancel();

    // B. Escuchar Transacciones PERSONALES (Siempre)
    print("🐈‍⬛2222222DDDDDD");
    _personalSub = _dbService.getDeudasStream(user.uid, null, false).listen((
      data,
    ) {
      _personalDeudas = data;
      _personalDeudas.sort(
        (a, b) => b.fechaLimite.compareTo(a.fechaLimite),
      ); // Ordenar por fecha
      print("🐈‍⬛333333333DDDDDDD");

      if (!_isSpaceMode) _isLoading = false;
      notifyListeners();
      print("🐈‍⬛4444444444444DDDDDDD");
    });
    print("🐈‍⬛5555555555555DDDDD");
    if (linkedSpaceId != null) {
      _spaceSub = _dbService
          .getDeudasStream(user.uid, linkedSpaceId, true) // true = es space
          .listen((data) {
            _spaceDeudas = data;
            _spaceDeudas.sort((a, b) => b.fechaLimite.compareTo(a.fechaLimite));

            // Si arrancamos en modo space, quitamos el loading aquí
            _isLoading = false;
            notifyListeners();
            print("🐈‍⬛66666666666666DDDDD");
          });
    } else {
      // Si no tiene space, aseguramos que la lista esté vacía
      _spaceDeudas = [];
      _isLoading = false; // Por si acaso
      print("🐈‍⬛777777777777DDDDDD");
    }
    print("🐈‍⬛888888888888888DDD");
  }

  // 2. AGREGAR DEUDA
  Future<void> addDeuda(
    Deuda d,
    TransactionProvider tProvdr,
    BuildContext ctx,
    dynamic stgs, // Settings
    bool generateAutoTransaction,
  ) async {
    print("😶‍🌫️😶‍🌫️😶‍🌫️ 5");
    // A. Guardar en Firebase
    await _dbService.addDeuda(d, _isSpaceMode);

    // B. Generar Transacción Automática (Si el usuario quiere)
    if (generateAutoTransaction) {
      String descriptionString =
          "${(d.debo ? stgs.lentFromText : stgs.lentToText)} ${d.involucrado} \n${stgs.descriptionText}: ${d.description}";

      print("😶‍🌫️😶‍🌫️😶‍🌫️ 9");
      // Usamos el provider de transacciones que ya está conectado a Firebase
      await tProvdr.addTransaction(
        Transaction(
          userId: d.userId,
          title: d.title,
          description: descriptionString,
          monto: d.monto,
          saldo: tProvdr
              .saldoActual, // Nota: El saldo se recalculará solo al bajar de Firebase
          fecha: d.fechaInicio,
          categoria: d.categoria,
          isExpense: !d.debo, // Si me deben (Ingreso), Si debo (Gasto)
          deudaAsociada: d.id,
        ),
      );
    }
  }

  // 3. BORRAR
  Future<void> deleteDeuda(Deuda d) async {
    await _dbService.deleteDeuda(d, _isSpaceMode);
  }

  // 4. ACTUALIZAR (Básico)
  Future<void> updateDeuda(Deuda updatedDeuda) async {
    await _dbService.updateDeuda(updatedDeuda, _isSpaceMode);
  }

  // 5. PAGAR DEUDA COMPLETA
  Future<void> pagarDeuda(
    Deuda d,
    TransactionProvider transProvider,
    BuildContext context,
  ) async {
    try {
      // Calculamos cuánto faltaba
      final montoRestante = d.monto - d.abono;

      // Creamos la transacción de pago
      await transProvider.addTransaction(
        Transaction(
          userId: FirebaseAuth.instance.currentUser!.uid,
          title: "${AppLocalizations.of(context)!.pagoDeText} ${d.title}",
          description: d.description,
          monto: montoRestante,
          saldo: transProvider.saldoActual,
          fecha: DateTime.now(),
          categoria: AppConstants.catDebt,
          isExpense: d.debo, // Si yo debía, pagar es un Gasto.
        ),
      );

      // Actualizamos la deuda a PAGADA
      d.pagada = true;
      d.abono = d.monto;

      // Guardamos en Firebase
      await updateDeuda(d);
    } catch (_) {
      //print("Error al pagar deuda: $e");
    }
  }

  // 6. ABONAR A DEUDA
  Future<AbonoStatus> abonarDeuda(
    Deuda d,
    double monto,
    TransactionProvider provider,
    BuildContext context,
  ) async {
    if (monto <= 0) return AbonoStatus.montoInvalido;

    // Pequeño margen de error para comparaciones de punto flotante
    if (monto > (d.monto - d.abono + 0.01)) return AbonoStatus.excedeDeuda;

    try {
      d.abono += monto;
      // Verificamos si ya se pagó completa
      if (d.abono >= d.monto - 0.01) {
        d.abono = d.monto; // Ajuste exacto
        d.pagada = true;
      }

      // Generamos la transacción del abono
      await provider.addTransaction(
        Transaction(
          userId: d.userId,
          title:
              "${(d.pagada ? AppLocalizations.of(context)!.pagoDeText : AppLocalizations.of(context)!.abonoForText)} ${d.title}",
          description: d.description,
          monto: monto,
          saldo: provider.saldoActual,
          fecha: DateTime.now(),
          categoria: AppConstants.catDebt,
          isExpense: d.debo,
          deudaAsociada: d.id,
        ),
      );

      // Actualizamos en Firebase
      await updateDeuda(d);

      return AbonoStatus.exito;
    } catch (e) {
      return AbonoStatus.error;
    }
  }

  // --- FILTROS (Ahora síncronos porque los datos ya están en memoria) ---

  List<Deuda> getDeudasDebo() {
    return deudas.where((deuda) => deuda.debo).toList();
  }

  List<Deuda> getDeudasMeDeben() {
    return deudas.where((deuda) => !deuda.debo).toList();
  }

  Deuda? getDeudaById(String id) {
    try {
      return deudas.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
}

enum AbonoStatus { exito, montoInvalido, excedeDeuda, error }
