import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  addTransaction(Transaction t){
    _transactions.add(t);
    notifyListeners();
  }
}
