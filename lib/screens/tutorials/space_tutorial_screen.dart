import 'package:flutter/material.dart';

class SpaceTutorialScreen extends StatelessWidget {
  const SpaceTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial de Espacios Compartidos'),
      ),
      body: const Center(
        child: Text('Contenido del tutorial sobre espacios compartidos.'),
      ),
    );
  }
}