import 'package:flutter/material.dart';
import 'package:money_move/models/transaction.dart';
import 'package:provider/provider.dart';
import '../providers/transactionProvider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final lista = provider.transactions;
    return Scaffold(
      appBar: AppBar(title: Text("MoneyMove")),
      body: lista.isEmpty
          ? Center(child: Text("No hay transacciones aun"))
          : ListView.builder(
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final transaction = lista[index];
                return ListTile(
                  title: Text(transaction.title),
                  subtitle: Text(transaction.monto.toString()),
                  leading: Icon(Icons.monetization_on),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          provider.addTransaction(
            Transaction(
              id: "0t",
              title: "Alimentos",
              description: "Bro ya funciono ya voy entendiendo",
              monto: 0.54,
              fecha: DateTime(2025, 11, 24),
              categoria: "Alimentos",
              isExpense: true,
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
