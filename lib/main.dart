import 'package:flutter/material.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/providers/ai_category_provider.dart';
import 'package:money_move/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import './services/database_helper.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TransactionProvider()..loadTransactions()),
      ChangeNotifierProvider(create: (_)=> AiCategoryProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,
      home: HomeScreen(),

      );
    
  }
}
