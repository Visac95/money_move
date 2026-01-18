import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? linkedAccountId; // <--- 1. Agregas esto (puede ser nulo)

  UserModel({
    required this.uid,
    required this.email,
    this.linkedAccountId, // <--- 2. Lo agregas al constructor
  });

  // Paso B: Lo lees en tu factory (donde conviertes el JSON a Objeto)
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      linkedAccountId: data['linkedAccountId'],
    );
  }
}
