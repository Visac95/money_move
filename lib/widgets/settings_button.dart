import 'package:flutter/material.dart';
import 'package:money_move/screens/settings_screen.dart';

Widget settingsButton(BuildContext context) {
  return IconButton(
    onPressed: () {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => SettingsScreen()));
    },
    icon: Icon(Icons.settings),
    padding: EdgeInsets.all(0),
  );
}
