import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
// import 'package:money_move/providers/space_provider.dart'; // Ya no es estrictamente necesario aquí si pasamos el ID directo
import 'package:money_move/services/database_service.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  User? _currentUser; // <--- Para saber quién es el usuario

  // 1. DOS LISTAS SEPARADAS (Tu nueva estrategia)
  List<Transaction> _personalTransactions = [];
  List<Transaction> _spaceTransactions = [];

  // 2. ESTADO
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSpaceMode = false;
  bool get isSpaceMode => _isSpaceMode;

  // 3. EL GETTER MÁGICO
  // Aquí ocurre la magia: dependiendo del switch, devolvemos una lista u otra.
  List<Transaction> get transactions =>
      _isSpaceMode ? _spaceTransactions : _personalTransactions;

  // Suscripciones independientes
  StreamSubscription? _personalSub;
  StreamSubscription? _spaceSub;

  // --------------------------------------------------------
  // 1. INICIALIZAR (Carga TODo lo necesario al principio)
  // --------------------------------------------------------
  void init(User? user, String? linkedSpaceId) {
    if (user == null) return;
    print("🐈‍⬛11111");

    _isLoading = true;
    notifyListeners();

    // A. Cancelar suscripciones viejas por si acaso
    _personalSub?.cancel();
    _spaceSub?.cancel();

    // B. Escuchar Transacciones PERSONALES (Siempre)
    print("🐈‍⬛2222222");
    _personalSub = _dbService
        .getTransactionsStream(user.uid, null, false) // false = no es space
        .listen((data) {
          _personalTransactions = data;
          _personalTransactions.sort(
            (a, b) => b.fecha.compareTo(a.fecha),
          ); // Ordenar por fecha
          print("🐈‍⬛333333333");

          // Solo quitamos el loading si estamos en modo personal o si no tiene space
          if (!_isSpaceMode) _isLoading = false;
          notifyListeners();
          print("🐈‍⬛4444444444444");
        });
    print("🐈‍⬛5555555555555");
    // C. Escuchar Transacciones SPACE (Solo si tiene ID vinculado)
    if (linkedSpaceId != null) {
      _spaceSub = _dbService
          .getTransactionsStream(
            user.uid,
            linkedSpaceId,
            true,
          ) // true = es space
          .listen((data) {
            _spaceTransactions = data;
            _spaceTransactions.sort((a, b) => b.fecha.compareTo(a.fecha));

            // Si arrancamos en modo space, quitamos el loading aquí
            _isLoading = false;
            notifyListeners();
            print("🐈‍⬛66666666666666");
          });
    } else {
      // Si no tiene space, aseguramos que la lista esté vacía
      _spaceTransactions = [];
      _isLoading = false; // Por si acaso
      print("🐈‍⬛777777777777");
    }
    print("🐈‍⬛888888888888888");
  }

  // --------------------------------------------------------
  // 2. EL SWITCHER (Ahora es súper sencillo)
  // --------------------------------------------------------
  void toggleTransactionMode(bool value) {
    _isSpaceMode = value;
    // Como los datos YA están en memoria en las variables _personal o _space,
    // solo avisamos a la UI que se redibuje. ¡Instantáneo! ⚡
    notifyListeners();
    print("🔄 Modo cambiado a: ${_isSpaceMode ? 'SPACE' : 'PERSONAL'}");
  }

  // --------------------------------------------------------
  // 3. CRUD (Agregar, Borrar, Editar)
  // --------------------------------------------------------

  Future<void> addTransaction(Transaction tx, bool spaceMode) async {
    await _dbService.addTransaction(tx, spaceMode);
  }

  Future<void> deleteTransaction(Transaction t) async {
    try {
      print("🗑️🗑️🗑️🗑️🗑️ Transacción borrada: $t.id");
      //if (_currentUser == null) return;

      await _dbService.deleteTransaction(t, _isSpaceMode);
      print("🗑️ Transacción borrada: ${t.id}");
    } catch (e) {
      print("❌ Error al borrar transacción: $e");
    }
  }

  Future<void> updateTransaction(Transaction tx) async {
    await _dbService.updateTransaction(tx, _isSpaceMode);
    notifyListeners();
  }

  // --------------------------------------------------------
  // 4. CÁLCULOS Y FILTROS (Simplificados usando el getter 'transactions')
  // --------------------------------------------------------

  // Nota: Al usar 'this.transactions' aquí, automáticamente usa la lista
  // correcta según el modo activo. No hay que cambiar nada de lógica.

  double get totalIngresos => transactions
      .where((t) => !t.isExpense)
      .fold(0.0, (sum, item) => sum + item.monto);

  double get totalEgresos => transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, item) => sum + item.monto);

  double get saldoActual => totalIngresos - totalEgresos;

  // ... (Tus otras funciones auxiliares getSaldoTransaction, getTransactionById) ...
  // Solo asegúrate de usar 'transactions' (el getter) en lugar de '_transactions'.
  double getSaldoTransaction(Transaction t) {
    if (t.isExpense) return t.saldo - t.monto;
    if (!t.isExpense) return t.saldo + t.monto;
    return 0.0;
  }

  Transaction? getTransactionById(String id) {
    try {
      return transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // ... (Tus filtros de fecha y categoría se mantienen igual, solo usa 'transactions') ...

  // EJEMPLO RAPIDO DE ADAPTACIÓN DE TUS FILTROS:
  String _filtroActual = "all";
  String _catFiltroActual = "all";

  // Getters para UI
  String get filtroActual => _filtroActual; // Agregué getter
  String get catFiltroActual => _catFiltroActual;

  void cambiarFiltro(String nuevo) {
    _filtroActual = nuevo;
    notifyListeners();
  }

  void cambiarCatFiltro(String nuevo) {
    _catFiltroActual = nuevo;
    notifyListeners();
  }

  List<Transaction> get transacionesParaMostrar {
    DateTime now = DateTime.now();
    // 1. Usamos el getter transactions (que ya tiene la lista correcta según el modo)
    List<Transaction> base = transactions;

    // 2. Filtro Categoría
    if (_catFiltroActual != "all") {
      base = base.where((t) => t.categoria == _catFiltroActual).toList();
    }

    // 3. Filtro Fecha (Tu lógica original)
    if (_filtroActual == "today") {
      return base
          .where(
            (tx) =>
                tx.fecha.year == now.year &&
                tx.fecha.month == now.month &&
                tx.fecha.day == now.day,
          )
          .toList();
    }
    // ... (Resto de tus filtros week, month, year) ...

    return base;
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

  //---------Filtro de categorias-----------
  List<Transaction> catFiltered(List<Transaction> list) {
    if (_catFiltroActual != "all") {
      return list // Corregido: filtrar sobre la lista que recibes, no siempre _transactions
          .where((t) => t.categoria == _catFiltroActual)
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _personalSub?.cancel();
    _spaceSub?.cancel();
    super.dispose();
  }
}
