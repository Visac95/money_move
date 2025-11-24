import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/transactionProvider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TransactionProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MoneyMoveApp",
      home: Scaffold(
        appBar: AppBar(title: Text("MoneyMove")),
        body: Center(child: Text("hola")),
        
      ),
    );
  }
}
