import 'package:flutter/material.dart';
import 'package:money_move/models/deuda.dart';

class EditDeudaScreen extends StatefulWidget {
  final Deuda deuda;

  const EditDeudaScreen({super.key, required this.deuda});

  @override
  State<EditDeudaScreen> createState() => _EditDeudaScreenState();
}

class _EditDeudaScreenState extends State<EditDeudaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Editar Deuda")),
      body: Center(child: Text("Editar deuda")),
    );
  }
}
