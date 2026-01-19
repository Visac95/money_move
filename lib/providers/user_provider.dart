import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/models/user_model.dart';
import 'package:money_move/services/database_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _usuarioActual = UserModel(uid: "", email: "", name: "");

  UserModel? get usuarioActual => _usuarioActual;

  void initSubscription() {
    final user = FirebaseAuth.instance.currentUser!;
    // ignore: no_leading_underscores_for_local_identifiers
    final DatabaseService _dbService = DatabaseService();

    FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            print("✅✅✅✅✅✅✅✅UserProvider line 25");
            print("${snapshot.data()}");
            _usuarioActual = UserModel.fromFirestore(snapshot);

            notifyListeners();
          } else {
            print("💀💀💀💀💀💀💀💀UserProvider line 25");
            _dbService.addUser(
              UserModel(
                uid: user.uid,
                email: user.email ?? "",
                name: user.displayName ?? "",
                photoUrl: user.photoURL,
              ),
            );
          }
        });
  }
}
