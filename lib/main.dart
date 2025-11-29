import 'package:flutter/material.dart';
import 'package:money_move/config/app_constants.dart';
import 'package:money_move/screens/home_screen.dart';
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
      title: AppConstants.appTitle,
      home: HomeScreen(),

      );
    
  }
}
