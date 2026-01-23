import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/deuda.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/models/user_model.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/services/database_service.dart';

class DeudaProvider extends ChangeNotifier {
  List<Deuda> _deudas = [];
  final DatabaseService _dbService = DatabaseService();

  List<Deuda> get deudas => _deudas;

  // 1. ESCUCHAR CAMBIOS (El corazón del sistema)
  void initSubscription(UserModel? userData) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _deudas = [];
      notifyListeners();
      return;
    }

    _dbService.getDeudasStream(user.uid).listen((event) {
      _deudas = event;
      // Ordenamos siempre por fecha límite (más urgente primero)
      _deudas.sort((a, b) => a.fechaLimite.compareTo(b.fechaLimite));
      notifyListeners();
    });
  }

  // 2. AGREGAR DEUDA
  Future<void> addDeuda(
    Deuda d,
    TransactionProvider tProvdr,
    BuildContext ctx,
    dynamic stgs, // Settings
    bool generateAutoTransaction,
    bool? isInSpace
  ) async {
    // A. Guardar en Firebase
    await _dbService.addDeuda(d);

    // B. Generar Transacción Automática (Si el usuario quiere)
    if (generateAutoTransaction) {
      String descriptionString =
          "${(d.debo ? stgs.lentFromText : stgs.lentToText)} ${d.involucrado} \n${stgs.descriptionText}: ${d.description}";

      // Usamos el provider de transacciones que ya está conectado a Firebase
      await tProvdr.addTransaction(
        Transaction(
          userId: FirebaseAuth.instance.currentUser!.uid,
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
        isInSpace
      );
    }
  }

  // 3. BORRAR
  Future<void> deleteDeuda(String id, String userId) async {
    await _dbService.deleteDeuda(id, userId);
  }

  // 4. ACTUALIZAR (Básico)
  Future<void> updateDeuda(Deuda updatedDeuda) async {
    await _dbService.updateDeuda(updatedDeuda);
  }

  // 5. PAGAR DEUDA COMPLETA
  Future<void> pagarDeuda(
    Deuda d,
    TransactionProvider transProvider,
    BuildContext context,
    bool isInSpace,
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
        isInSpace,
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
    bool? isInSpace
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
          userId: FirebaseAuth.instance.currentUser!.uid,
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
        isInSpace
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
    return _deudas.where((deuda) => deuda.debo).toList();
  }

  List<Deuda> getDeudasMeDeben() {
    return _deudas.where((deuda) => !deuda.debo).toList();
  }

  Deuda? getDeudaById(String id) {
    try {
      return _deudas.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
}

enum AbonoStatus { exito, montoInvalido, excedeDeuda, error }
