import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/services/database_service.dart';
import '../models/transaction.dart';
// BORRADO: import '../services/database_helper.dart'; (Ya no lo necesitamos)

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  final DatabaseService _dbService = DatabaseService();

  List<Transaction> get transactions => _transactions;

  // 1. ESCUCHAR EN TIEMPO REAL (Esto mantiene la lista actualizada siempre)
  void initSubscription() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _transactions = []; // Si no hay usuario, limpiamos la lista
      notifyListeners();
      return;
    }

    _dbService.getTransactionsStream(user.uid).listen((event) {
      _transactions = event;
      notifyListeners(); 
    });
  }

  // 2. AGREGAR
  Future<void> addTransaction(Transaction tx) async {
    await _dbService.addTransaction(tx);
  }

  // 3. BORRAR
  Future<void> deleteTransaction(String id) async {
    await _dbService.deleteTransaction(id);
  }

  // 4. ACTUALIZAR (Corregido para usar Firebase)
  Future<void> updateTransaction(Transaction updatedTransaction) async {
    // Llamamos a Firebase
    await _dbService.updateTransaction(updatedTransaction);
    
    // NOTA: No necesitamos actualizar la lista _transactions manualmente aquí.
    // Al actualizar en la nube, Firebase dispara el "listen" de arriba
    // y la lista se actualiza sola mágicamente. ✨
  }

  // --- TUS CÁLCULOS Y FILTROS (SE QUEDAN IGUAL) ---

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

  double getSaldoTransaction(Transaction t) {
    if (t.isExpense) {
      return t.saldo - t.monto;
    }
    if (!t.isExpense) {
      return t.saldo + t.monto;
    }
    return 0.0;
  }

  Transaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  //_______FILTRO________
  String _filtroActual = "all";

  void cambiarFiltro(String nuevoFiltro) {
    _filtroActual = nuevoFiltro;
    notifyListeners();
  }

  List<Transaction> get transacionesParaMostrar {
    DateTime now = DateTime.now();
    
    // Filtro base por categoría
    List<Transaction> baseList = catFiltered(_transactions);

    if (_filtroActual == "today") {
      return baseList
          .where(
            (tx) =>
                tx.fecha.year == now.year &&
                tx.fecha.month == now.month &&
                tx.fecha.day == now.day,
          )
          .toList();
    }
    if (_filtroActual == "month") {
      return baseList
          .where(
            (tx) => tx.fecha.year == now.year && tx.fecha.month == now.month,
          )
          .toList();
    }
    if (_filtroActual == "year") {
      return baseList
          .where((tx) => tx.fecha.year == now.year)
          .toList();
    }
    if (_filtroActual == "week") {
      return baseList.where((tx) {
        DateTime startWeek = now.subtract(Duration(days: now.weekday - 1));
        DateTime startWeekClean = DateTime(
          startWeek.year,
          startWeek.month,
          startWeek.day,
        );
        return tx.fecha.isAfter(startWeekClean) ||
            tx.fecha.isAtSameMomentAs(startWeekClean);
      }).toList();
    }

    return baseList.toList();
  }

  String getActualFilterString(BuildContext ctx) {
    final st = AppLocalizations.of(ctx)!;
    if (_filtroActual == "today") return st.hoyText;
    if (_filtroActual == "week") return st.thisWeekText;
    if (_filtroActual == "month") return st.thisMonthText;
    if (_filtroActual == "year") return st.thisYearText;
    return st.todoText;
  }

  //____GETTERS FILTROS________
  double get filteredIngresos {
    Iterable<Transaction> listaFiltradaIngresos = transacionesParaMostrar.where(
      (t) => t.isExpense == false,
    );
    return listaFiltradaIngresos.fold(
      0.0,
      (sumaAcumulada, item) => sumaAcumulada + item.monto,
    );
  }

  double get filteredEgresos {
    Iterable<Transaction> listaFiltradaEgresos = transacionesParaMostrar.where(
      (t) => t.isExpense == true,
    );
    return listaFiltradaEgresos.fold(
      0.0,
      (sumaAcumulada, item) => sumaAcumulada + item.monto,
    );
  }

  double get filteredsaldoActual => filteredIngresos - filteredEgresos;

  String _catFiltroActual = "all";
  String get catFiltroActual => _catFiltroActual;

  void cambiarCatFiltro(String nuevoFiltro) {
    _catFiltroActual = nuevoFiltro;
    notifyListeners();
  }

  //---------Filtro de categorias-----------
  List<Transaction> catFiltered(List<Transaction> list) {
    if (_catFiltroActual != "all") {
      return list // Corregido: filtrar sobre la lista que recibes, no siempre _transactions
          .where((t) => t.categoria == _catFiltroActual)
          .toList();
    }
    return list;
  }
}