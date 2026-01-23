import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/models/user_model.dart';
import 'package:money_move/providers/space_provider.dart';
import 'package:money_move/providers/user_provider.dart';
import 'package:money_move/services/database_service.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  final DatabaseService _dbService = DatabaseService();

  bool _isLoading = true; // 1. Empieza cargando
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  List<Transaction> get transactions => _transactions;

  // Suscripción
  StreamSubscription? _subscription;

  bool _isSpaceMode = false;
  bool get isSpaceMode => _isSpaceMode;

  User? _currentUser;
  String? _currentSpaceId;

  // 1. INICIALIZAR (Se llama al inicio)
  void init(User? user, String? spaceId) {
    _currentUser = user;
    _currentSpaceId = spaceId;
    _escucharTransacciones(); // Llama a la función interna
  }

  // 2. CAMBIAR MODO (Esto lo llama tu botón Switcher)
  void toggleTransactionMode(bool value) {
    _isSpaceMode = value;
    notifyListeners(); // Actualiza el UI del botón visualmente
    _escucharTransacciones(); // <--- IMPORTANTE: REINICIA EL STREAM
  }

  // 3. LÓGICA INTERNA (Rompe tubería vieja, crea nueva)
  void _escucharTransacciones() {
    if (_currentUser == null) return;

    // A. Ponemos cargando
    _isLoading = true;
    notifyListeners();

    // B. CANCELAMOS LA SUSCRIPCIÓN ANTERIOR (Vital)
    _subscription?.cancel();

    // C. CREAMOS LA NUEVA CONEXIÓN SEGÚN EL MODO
    final stream = _dbService.getTransactionsStream(
      _currentUser!.uid,
      _currentSpaceId,
      _isSpaceMode, // <--- Aquí pasamos el valor actual del switch
    );

    // D. ESCUCHAMOS
    _subscription = stream.listen(
      (nuevasTransacciones) {
        _transactions = nuevasTransacciones;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        print("Error: $e");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // TU FUNCION ACTUAL (Déjala igual, es correcta)
  void initSubscription(UserModel? userData, SpaceProvider? spaceProv) {
    _isLoading = true; // Empieza carga
    notifyListeners(); // Avisa a la UI

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (spaceProv!.isInSpace) {
      // Si hay cuenta vinculada, escuchamos esa
      _transactions = [];
      _dbService
          .getTransactionsStream(user.uid, userData!.linkedAccountId, true)
          .listen((event) {
            _transactions = event;
            _transactions.sort((b, a) => a.fecha.compareTo(b.fecha));
            notifyListeners();
          });
      _isLoading = true;
      return;
    }
    _dbService
        .getTransactionsStream(user.uid, userData?.linkedAccountId, false)
        .listen((event) {
          _transactions = event;
          _transactions.sort((b, a) => a.fecha.compareTo(b.fecha));
          notifyListeners();
        });

    _isLoading = false; // 2. Termina carga
    notifyListeners(); // 3. Avisa a la UI para quitar la pantalla
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
  // En tu TransactionProvider

  Future<void> updateTransaction(Transaction transactionEditada) async {
    try {
      await _dbService.updateTransaction(transactionEditada);
      // Si usas notifyListeners() para actualizar algo local manual, ponlo aquí.
      notifyListeners();
    } catch (_) {
      //hola
    }
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
      return baseList.where((tx) => tx.fecha.year == now.year).toList();
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
