import 'package:flutter/material.dart';

class ListaDeudasWidget extends StatefulWidget {
  const ListaDeudasWidget({super.key});

  @override
  State<ListaDeudasWidget> createState() => _ListaDeudasWidgetState();
}

class _ListaDeudasWidgetState extends State<ListaDeudasWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Deudas"),);
  }
}