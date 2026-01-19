import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final String? linkedAccountId;
  final String? spaceId;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    this.linkedAccountId,
    this.spaceId,
  });

  // Paso B: Lo lees en tu factory (donde conviertes el JSON a Objeto)
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      linkedAccountId: data['linkedAccountId'],
      spaceId: data['spaceId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "photoUrl": photoUrl,
      "linkedAccountId": linkedAccountId,
      "spaceId": spaceId,
    };
  }
}
