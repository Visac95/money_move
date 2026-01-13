import 'package:flutter/material.dart';
import 'package:money_move/l10n/app_localizations.dart';
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

  double getSaldoTransaction(Transaction t) {
    if (t.isExpense) {
      return t.saldo - t.monto;
    }
    if (!t.isExpense) {
      return t.saldo + t.monto;
    }

    return 0.0;
  }

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
  String _filtroActual = "all";

  void cambiarFiltro(String nuevoFiltro) {
    _filtroActual = nuevoFiltro;
    notifyListeners();
  }

  List<Transaction> get transacionesParaMostrar {
    DateTime now = DateTime.now();
    if (_filtroActual == "today") {
      return catFiltered(_transactions)
          .where(
            (tx) =>
                tx.fecha.year == now.year &&
                tx.fecha.month == now.month &&
                tx.fecha.day == now.day,
          )
          .toList();
    }
    if (_filtroActual == "month") {
      return catFiltered(_transactions)
          .where(
            (tx) => tx.fecha.year == now.year && tx.fecha.month == now.month,
          )
          .toList();
    }
    if (_filtroActual == "year") {
      return catFiltered(
        _transactions,
      ).where((tx) => tx.fecha.year == now.year).toList();
    }
    if (_filtroActual == "week") {
      return catFiltered(_transactions).where((tx) {
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

    return catFiltered(_transactions).toList();
  }

  String getActualFilterString(BuildContext ctx) {
    final st = AppLocalizations.of(ctx)!;
    if (_filtroActual == "today") {
      return st.hoyText;
    }
    if (_filtroActual == "week") {
      return st.thisWeekText;
    }
    if (_filtroActual == "month") {
      return st.thisMonthText;
    }
    if (_filtroActual == "year") {
      return st.thisYearText;
    }
    return st.todoText;
  }

  //____GETTERS FILTROS________
  // Getter de ingresos
  double get filteredIngresos {
    Iterable<Transaction> listaFiltradaIngresos = transacionesParaMostrar.where(
      (t) => t.isExpense == false,
    );
    return listaFiltradaIngresos.fold(
      0.0,
      (sumaAcumulada, item) => sumaAcumulada + item.monto,
    );
  }

  // Getter de egresos
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

  // ignore: prefer_final_fields
  String _catFiltroActual = "all";

  String get catFiltroActual => _catFiltroActual;

  void cambiarCatFiltro(String nuevoFiltro) {
    _catFiltroActual = nuevoFiltro;
    notifyListeners();
  }

  //---------Filtro de categorias-----------
  List<Transaction> catFiltered(List<Transaction> list) {
    if (_catFiltroActual != "all") {
      return _transactions
          .where((t) => t.categoria == _catFiltroActual)
          .toList();
    }
    return _transactions;
  }

  // Dentro de la clase TransactionProvider...

  void generateMockData() {
    final now = DateTime.now();

    // Lista de datos falsos ajustada a TU modelo
    final List<Transaction> mockTransactions = [
      // --- HOY ---
      Transaction(
        id: 'mock_1',
        title: 'Diseño Freelance',
        description: 'Pago por diseño de logo',
        monto: 150.00,
        saldo: 5150.00, // Simulamos un saldo acumulado
        fecha: now,
        isExpense: false, // Es un INGRESO
        categoria: 'cat_job',
      ),
      Transaction(
        id: 'mock_2',
        title: 'Starbucks',
        description: 'Café y Bagel',
        monto: 12.50,
        saldo: 5137.50,
        fecha: now,
        isExpense: true, // Es un GASTO
        categoria: 'cat_home',
      ),

      // --- AYER ---
      Transaction(
        id: 'mock_3',
        title: 'Supermercado',
        description: 'Compras de la semana',
        monto: 85.00,
        saldo: 5052.50,
        fecha: now.subtract(const Duration(days: 1)),
        isExpense: true,
        categoria: 'cat_pet',
      ),

      // --- HACE 2 DÍAS ---
      Transaction(
        id: 'mock_4',
        title: 'Venta de Garage',
        description: 'Vendí la bici vieja',
        monto: 200.00,
        saldo: 5252.50,
        fecha: now.subtract(const Duration(days: 2)),
        isExpense: false, // INGRESO
        categoria: 'cat_pet',
      ),
      Transaction(
        id: 'mock_5',
        title: 'Gasolina',
        description: 'Tanque lleno',
        monto: 40.00,
        saldo: 5212.50,
        fecha: now.subtract(const Duration(days: 3)),
        isExpense: true,
        categoria: 'cat_pet',
      ),

      // --- HACE 4 DÍAS ---
      Transaction(
        id: 'mock_6',
        title: 'Cena con amigos',
        description: 'Pizzas y bebidas',
        monto: 120.00,
        saldo: 5092.50,
        fecha: now.subtract(const Duration(days: 4)),
        isExpense: true,
        categoria: 'cat_pet',
      ),

      // --- HACE 6 DÍAS ---
      Transaction(
        id: 'mock_7',
        title: 'Spotify',
        description: 'Suscripción mensual',
        monto: 15.00,
        saldo: 5077.50,
        fecha: now.subtract(const Duration(days: 6)),
        isExpense: false,
        categoria: 'cat_pet',
      ),
    ];

    // Agregamos todo a la lista existente
    _transactions.addAll(mockTransactions);

    // Avisamos a los gráficos
    notifyListeners();
  }
}
