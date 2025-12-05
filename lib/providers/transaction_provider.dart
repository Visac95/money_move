import 'package:flutter/material.dart';
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
    Iterable<Transaction> listaFiltradaIngresos = _transactions.where((t) => t.isExpense == false);
    return listaFiltradaIngresos.fold(0.0, (sumaAcumulada, item) => sumaAcumulada + item.monto);
  }

  // Getter de egresos
  double get totalEgresos {
    Iterable<Transaction> listaFiltradaEgresos = _transactions.where((t) => t.isExpense == true);
    return listaFiltradaEgresos.fold(0.0, (sumaAcumulada, item) => sumaAcumulada + item.monto);
  }

  double get saldoActual => totalIngresos - totalEgresos;
}