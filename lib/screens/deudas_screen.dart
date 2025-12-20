import 'package:flutter/material.dart';
import 'package:money_move/widgets/add_deuda_button.dart';
import 'package:money_move/widgets/lista_deudas_widget.dart';

class DeudasScreen extends StatefulWidget {
  const DeudasScreen({super.key});

  @override
  State<DeudasScreen> createState() => _DeudasScreenState();
}

class _DeudasScreenState extends State<DeudasScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(title: Text("Deudas")),
      body: Column(
        children: [
          ListaDeudasWidget(),
        ],
      ),
      floatingActionButton: AddDeudaButton(),
    );
  }
}