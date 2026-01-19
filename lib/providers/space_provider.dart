import 'package:flutter/material.dart';

class SpaceProvider extends ChangeNotifier {
  bool _isSharedMode = false;

  bool get isSharedMode => _isSharedMode;

  void toogleMode() {
    _isSharedMode = !_isSharedMode;
    notifyListeners();
  }

  void setSharedMode(bool value) {
    _isSharedMode = value;
    notifyListeners();
  }
}
