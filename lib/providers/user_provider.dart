import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:money_move/models/user_model.dart';
import 'package:money_move/services/database_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _usuarioActual = UserModel(uid: "", email: "");

  UserModel? get usuarioActual => _usuarioActual;

  void initSubscription() {
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection("users")
        .doc(myUid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            _usuarioActual = UserModel.fromFirestore(snapshot);

            notifyListeners();
          }
        });
  }
}
