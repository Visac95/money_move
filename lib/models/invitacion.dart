class Invitacion {
  final String codeInvitacion;
  final String linkInvitacion;
  final DateTime creationDate;
  final String creatorId;
  final String spaceId;

  Invitacion({
    required this.codeInvitacion,
    required this.linkInvitacion,
    required this.creationDate,
    required this.creatorId,
    required this.spaceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'codeInvitacion': codeInvitacion,
      'linkInvitacion': linkInvitacion,
      'creationDate': creationDate.toIso8601String(),
      'creatorId': creatorId,
      'spaceId': spaceId,
    };
  }

  factory Invitacion.fromMap(Map<String, dynamic> map) {
    return Invitacion(
      codeInvitacion: map['codeInvitacion'],
      linkInvitacion: map['linkInvitacion'],
      creationDate: DateTime.parse(map['creationDate']),
      creatorId: map['creatorId'],
      spaceId: map['spaceId'],
    );
  }
}
