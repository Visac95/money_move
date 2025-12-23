import 'package:flutter/material.dart';
import 'package:money_move/models/deuda.dart';
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

    _deudas.sort((a, b) => b.fechaLimite.compareTo(a.fechaLimite));

    notifyListeners();
  }

  Future<void> deleteDeuda(String id) async {
    await DatabaseHelper.instance.deleteDeuda( id);

    _deudas.removeWhere((item)=>item.id == id);
    notifyListeners();
  }

  Future<void> updateDeuda(Deuda updatedDeuda) async{
    await DatabaseHelper.instance.updateDeuda(updatedDeuda);

    int index = _deudas.indexWhere((t)=> t.id == updatedDeuda.id);
    if (index != -1){
      _deudas[index] = updatedDeuda;

      _deudas.sort((a, b) => b.fechaLimite.compareTo(a.fechaLimite));
      notifyListeners();
    }
  }

  Future<List<Deuda>> getDeudasDebo() async {
    return _deudas.where((deuda) => deuda.debo).toList();
  }

  Future<List<Deuda>> getDeudasMeDeben() async {
    return _deudas.where((deuda) => !deuda.debo).toList();
  }

}
