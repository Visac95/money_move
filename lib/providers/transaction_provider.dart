import 'package:flutter/material.dart';
import 'package:money_move/models/filtros.dart';
import '../models/transaction.dart';
import '../services/database_helper.dart'; // <--- IMPORTANTE: Importar el mayordomo

class TransactionProvider extends ChangeNotifier {
  // 1. Ya no es 'final' porque la vamos a llenar después desde la base de datos
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  // --- ESTA ES LA FUNCIÓN QUE TE FALTABA 👇 ---
  Future<void> loadTransactions() async {
    // Le pedimos al mayordomo que traiga todo de la base de datos

    _transactions = await DatabaseHelper.instance.getAllTransactions();

    notifyListeners();
  }

  // --- AGREGAR CON BASE DE DATOS ---
  Future<void> addTransaction(Transaction t) async {
    // 1. Guardar en el disco (BD)
    await DatabaseHelper.instance.insertTransaction(t);

    // 2. Actualizar la lista en pantalla
    _transactions.add(t);
    // Ordenamos por fecha (opcional)
    _transactions.sort((a, b) => b.fecha.compareTo(a.fecha));

    notifyListeners();
  }

  // --- BORRAR CON BASE DE DATOS ---
  Future<void> deleteTransaction(String id) async {
    // 1. Borrar del disco (BD)
    await DatabaseHelper.instance.deleteTransaction(id);

    // 2. Borrar de la lista en pantalla
    _transactions.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // --- TUS CÁLCULOS (ESTOS ESTABAN BIEN, LOS DEJAMOS IGUAL) ---

  // Getter de ingresos
  double get totalIngresos {
    Iterable<Transaction> listaFiltradaIngresos = _transactions.where(
      (t) => t.isExpense == false,
    );
    return listaFiltradaIngresos.fold(
      0.0,
      (sumaAcumulada, item) => sumaAcumulada + item.monto,
    );
  }

  // Getter de egresos
  double get totalEgresos {
    Iterable<Transaction> listaFiltradaEgresos = _transactions.where(
      (t) => t.isExpense == true,
    );
    return listaFiltradaEgresos.fold(
      0.0,
      (sumaAcumulada, item) => sumaAcumulada + item.monto,
    );
  }

  double get saldoActual => totalIngresos - totalEgresos;

  Future<void> updateTransaction(Transaction updatedTransaction) async {
    // 1. Actualizar en la base de datos
    await DatabaseHelper.instance.updateTransaction(updatedTransaction);

    // 2. Actualizar en la lista en memoria
    int index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      // Ordenamos por fecha (opcional)
      _transactions.sort((a, b) => b.fecha.compareTo(a.fecha));
      notifyListeners();
    }
  }

  Transaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null; // Si no se encuentra, retornamos null
    }
  }

  //_______FILTRO________
  // ignore: prefer_final_fields
  Filtros _filtroActual = Filtros.ever;

  void CambiarFiltro(Filtros nuevoFiltro) {
    _filtroActual = nuevoFiltro;
    notifyListeners();
  }

  List<Transaction> get transacionesParaMostrar {
    DateTime now = DateTime.now();
    if (_filtroActual == Filtros.today) {
      return _transactions
          .where(
            (tx) =>
                tx.fecha.year == now.year &&
                tx.fecha.month == now.month &&
                tx.fecha.day == now.day,
          )
          .toList();
    }
    if (_filtroActual == Filtros.month) {
      return _transactions
          .where(
            (tx) => tx.fecha.year == now.year && tx.fecha.month == now.month,
          )
          .toList();
    }
    if (_filtroActual == Filtros.year) {
      return _transactions.where((tx) => tx.fecha.year == now.year).toList();
    }
  }
}
