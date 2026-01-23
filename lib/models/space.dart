import 'package:cloud_firestore/cloud_firestore.dart';

class Space {
  final String spaceId;
  final List<String> memberIds;
  final DateTime createdAt;

  Space({
    required this.spaceId,
    required this.memberIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'spaceId': spaceId,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Space.fromMap(Map<String, dynamic> map) {
    return Space(
      spaceId: map['spaceId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      // Si el dato existe lo convierte, si es null (??) pone la fecha de hoy
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
