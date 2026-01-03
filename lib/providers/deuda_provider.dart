import 'package:flutter/material.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/deuda.dart';
import 'package:money_move/models/transaction.dart';
import 'package:money_move/providers/transaction_provider.dart';
import 'package:money_move/services/database_helper.dart';

class DeudaProvider extends ChangeNotifier {
  List<Deuda> _deudas = [];

  List<Deuda> get deudas => _deudas;

  Future<void> loadDeudas() async {
    _deudas = await DatabaseHelper.instance.getAllDeudas();
    notifyListeners();
  }

  Future<void> addDeuda(Deuda d) async {
    await DatabaseHelper.instance.insertDeuda(d);

    _deudas.add(d);

    _deudas.sort((a, b) => a.fechaLimite.compareTo(b.fechaLimite));

    notifyListeners();
  }

  Future<void> deleteDeuda(String id) async {
    await DatabaseHelper.instance.deleteDeuda(id);

    _deudas.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> updateDeuda(Deuda updatedDeuda) async {
    // 1. ACTUALIZACIÓN OPTIMISTA (Primero memoria y UI)
    int index = _deudas.indexWhere((t) => t.id == updatedDeuda.id);
    if (index != -1) {
      _deudas[index] = updatedDeuda;
      // Ordenamos
      _deudas.sort((a, b) => b.fechaLimite.compareTo(a.fechaLimite));
      // ¡Notificamos YA! La UI se actualiza instantáneamente aquí
      notifyListeners();
    }

    // 2. PERSISTENCIA (Base de datos después, sin bloquear la UI visualmente)
    try {
      await DatabaseHelper.instance.updateDeuda(updatedDeuda);
    } catch (e) {
      return;
    }
  }

  Future<void> pagarDeuda(
    Deuda d,
    TransactionProvider transProvider,
    BuildContext context,
  ) async {
    try {
      // 1. Calculamos valores antes de modificar nada
      final montoRestante = d.monto - d.abono;

      // 2. Preparamos el objeto transacción
      transProvider.addTransaction(
        Transaction(
          title: "${AppLocalizations.of(context)!.pagoDeText} ${d.title}",
          description: d.description,
          monto: montoRestante,
          fecha: DateTime.now(),
          categoria: AppConstants.catDebt,
          isExpense: d.debo,
        ),
      );

      // 3. Actualizamos el objeto local en memoria (esto es instantáneo)
      d.pagada = true;
      d.abono = d.monto;

      updateDeuda(d);

      notifyListeners();
    } catch (e) {
      return;
    }
  }

  Future<AbonoStatus> abonarDeuda(
    Deuda d,
    double monto,
    TransactionProvider provider,
    BuildContext context,
  ) async {
    if (monto == 0 || monto < 0) {
      return AbonoStatus.montoInvalido;
    } else if (monto > (d.monto - d.abono)) {
      return AbonoStatus.excedeDeuda;
    }

    try {
      d.abono += monto;
      if (d.abono >= d.monto) {
        d.pagada = true;
      }

      //Generamos la transaccion
      provider.addTransaction(
        Transaction(
          title:
              "${(d.pagada ? AppLocalizations.of(context)!.pagoDeText : AppLocalizations.of(context)!.abonoForText)} ${d.title}",
          description: d.description,
          monto: monto,
          fecha: DateTime.now(),
          categoria: AppConstants.catDebt,
          isExpense: d.debo,
          deudaAsociada: d.id,
        ),
      );

      updateDeuda(d);

      notifyListeners();
      return AbonoStatus.exito; // <--- Todo salió bien
    } catch (e) {
      return AbonoStatus.error;
    }
  }

  Future<List<Deuda>> getDeudasDebo() async {
    final l = _deudas.where((deuda) => deuda.debo).toList();
    l.sort((a, b) => b.fechaLimite.compareTo(a.fechaLimite));
    return l;
  }

  Future<List<Deuda>> getDeudasMeDeben() async {
    final l = _deudas.where((deuda) => !deuda.debo).toList();
    l.sort((a, b) => b.fechaLimite.compareTo(a.fechaLimite));
    return l;
  }

  Deuda? getDeudaById(String id) {
    try {
      return _deudas.firstWhere((d) => d.id == id);
    } catch (e) {
      return null; // Si no se encuentra, retornamos null
    }
  }
}

enum AbonoStatus {
  exito,
  montoInvalido, // Negativo o cero
  excedeDeuda, // Intenta pagar más de lo que debe
  error,
}
