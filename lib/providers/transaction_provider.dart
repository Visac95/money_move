import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
import 'package:money_move/services/database_service.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  // 1. VARIABLES DE ESTADO (Ahora inyectadas desde fuera)
  User? _currentUser;
  String? _currentSpaceId;

  // Esta variable ya no la cambiamos nosotros, nos la pasan desde SpaceProvider
  bool _isSpaceMode = false;

  // 2. LISTAS DE DATOS
  List<Transaction> _personalTransactions = [];
  List<Transaction> _spaceTransactions = [];

  bool _isLoading = true;

  // GETTERS PÚBLICOS
  bool get isLoading => _isLoading;
  bool get isSpaceMode => _isSpaceMode;

  // EL GETTER MÁGICO 🪄
  // Decide qué lista mostrar basado en lo que diga SpaceProvider
  List<Transaction> get transactions =>
      _isSpaceMode ? _spaceTransactions : _personalTransactions;

  // Suscripciones
  StreamSubscription? _personalSub;
  StreamSubscription? _spaceSub;

  // --------------------------------------------------------
  // 🔥 1. MÉTODO DE CONEXIÓN (El Corazón del Proxy)
  // --------------------------------------------------------
  // Este método se llamará automáticamente desde main.dart cuando algo cambie
  void updateFromExternal(User? user, String? spaceId, bool isSpaceModeInput) {
    // ignore: unused_local_variable
    bool dataChanged = false;

    // A. Actualizamos el modo visual (Switch)
    if (_isSpaceMode != isSpaceModeInput) {
      _isSpaceMode = isSpaceModeInput;
      print(
        "🔄 TransactionProvider: Modo actualizado a ${_isSpaceMode ? 'SPACE' : 'PERSONAL'}",
      );
      notifyListeners(); // Avisamos rápido para que la UI cambie la lista
    }

    // B. Detectamos si cambió el Usuario o el Grupo (Para recargar los Streams)
    if (_currentUser?.uid != user?.uid || _currentSpaceId != spaceId) {
      _currentUser = user;
      _currentSpaceId = spaceId;
      _initStreams(); // Recargamos las conexiones a Firebase
      dataChanged = true;
    }

    // Si solo cambió el modo, ya notificamos arriba.
    // Si cambiaron los datos (streams), _initStreams notificará cuando lleguen datos.
  }

  // --------------------------------------------------------
  // 2. INICIALIZAR STREAMS (Privado)
  // --------------------------------------------------------
  void _initStreams() {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    print("🐈‍⬛ Iniciando Streams de Transacciones...");

    // A. Cancelar suscripciones viejas
    _personalSub?.cancel();
    _spaceSub?.cancel();

    // B. Escuchar Transacciones PERSONALES (Siempre)
    _personalSub = _dbService
        .getTransactionsStream(_currentUser!.uid, null, false)
        .listen((data) {
          _personalTransactions = data;
          _personalTransactions.sort((a, b) => b.fecha.compareTo(a.fecha));

          // Solo quitamos loading si estamos viendo personal
          if (!_isSpaceMode) _isLoading = false;
          notifyListeners();
          print("🐈‍⬛ Datos Personales recibidos: ${data.length}");
        });

    // C. Escuchar Transacciones SPACE (Solo si hay ID vinculado)
    if (_currentSpaceId != null && _currentSpaceId!.isNotEmpty) {
      _spaceSub = _dbService
          .getTransactionsStream(_currentUser!.uid, _currentSpaceId, true)
          .listen((data) {
            _spaceTransactions = data;
            _spaceTransactions.sort((a, b) => b.fecha.compareTo(a.fecha));

            // Si estamos en modo space, quitamos loading
            _isLoading = false;
            notifyListeners();
            print("🐈‍⬛ Datos Space recibidos: ${data.length}");
          });
    } else {
      _spaceTransactions = [];
      if (_isSpaceMode) _isLoading = false;
    }
  }

  // --------------------------------------------------------
  // 3. CRUD (Agregar, Borrar, Editar)
  // --------------------------------------------------------

  Future<void> addTransaction(Transaction tx) async {
    // Usamos la variable _isSpaceMode que recibimos del SpaceProvider
    // para saber dónde guardar.
    await _dbService.addTransaction(tx, _isSpaceMode);
  }

  Future<void> deleteTransaction(Transaction t) async {
    try {
      if (_currentUser == null) return;
      await _dbService.deleteTransaction(
        t,
        (_isSpaceMode && _currentSpaceId != null),
      );

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
  // 4. CÁLCULOS Y FILTROS
  // --------------------------------------------------------

  double get totalIngresos => transactions
      .where((t) => !t.isExpense)
      .fold(0.0, (sum, item) => sum + item.monto);

  double get totalEgresos => transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, item) => sum + item.monto);

  double get saldoActual => totalIngresos - totalEgresos;

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

  // FILTROS DE FECHA Y CATEGORÍA
  String _filtroActual = "all";
  String _catFiltroActual = "all";

  String get filtroActual => _filtroActual;
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
    List<Transaction> base = transactions;

    // Filtro Categoría
    if (_catFiltroActual != "all") {
      base = base.where((t) => t.categoria == _catFiltroActual).toList();
    }

    // Filtro Fecha
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
    if (_filtroActual == "week") {
      // Lógica simplificada de semana (puedes ajustar si tienes utils)
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      startOfWeek = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      ); // medianoche
      return base
          .where(
            (tx) => tx.fecha.isAfter(
              startOfWeek.subtract(const Duration(seconds: 1)),
            ),
          )
          .toList();
    }
    if (_filtroActual == "month") {
      return base
          .where(
            (tx) => tx.fecha.year == now.year && tx.fecha.month == now.month,
          )
          .toList();
    }
    if (_filtroActual == "year") {
      return base.where((tx) => tx.fecha.year == now.year).toList();
    }

    return base; // "all"
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
    return transacionesParaMostrar
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, item) => sum + item.monto);
  }

  double get filteredEgresos {
    return transacionesParaMostrar
        .where((t) => t.isExpense)
        .fold(0.0, (sum, item) => sum + item.monto);
  }

  double get filteredsaldoActual => filteredIngresos - filteredEgresos;

  List<Transaction> catFiltered(List<Transaction> list) {
    if (_catFiltroActual != "all") {
      return list.where((t) => t.categoria == _catFiltroActual).toList();
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
