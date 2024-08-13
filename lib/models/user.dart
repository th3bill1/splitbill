class User {
  String id;
  String name;
  String email;
  List<String> friends;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.friends,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'friends': friends,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      friends: List<String>.from(map['friends'] ?? []),
    );
  }
}
