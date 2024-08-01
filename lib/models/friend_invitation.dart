class FriendInvitation {
  String id;
  String fromUserId;
  String toUserId;

  FriendInvitation({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
    };
  }

  static FriendInvitation fromMap(Map<String, dynamic> map) {
    return FriendInvitation(
      id: map['id'],
      fromUserId: map['fromUserId'],
      toUserId: map['toUserId'],
    );
  }
}
