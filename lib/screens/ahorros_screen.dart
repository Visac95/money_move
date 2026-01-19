import 'package:flutter/material.dart';

class AhorrosScreen extends StatelessWidget {
  const AhorrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ahorros'),
      ),
      body: const Center(
        child: Text('Pantalla de Ahorros'),
      ),
    );
  }
}