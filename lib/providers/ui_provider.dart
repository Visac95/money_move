import 'package:flutter/material.dart';

class UiProvider extends ChangeNotifier{
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  set selectedIndex (int index){
    _selectedIndex = index;
    notifyListeners();
  }

  // --------------------------------------------------------
  // RESETEO DE UI (Para cerrar sesión)
  // --------------------------------------------------------
  void clearData() {
    _selectedIndex = 0;
    notifyListeners();
    print("🧹 UiProvider reseteado (Volviendo a la pestaña principal).");
  }
}