class User {
  int? id;
  String username;
  String password;
  String? topic;
  double? threshold;

  User(
      {this.id,
      required this.username,
      required this.password,
      this.topic,
      this.threshold});

  // Convert User object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'topic': topic,
      'threshold': threshold
    };
  }

  // Convert a Map to a User object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      topic: map['topic'],
    );
  }
}