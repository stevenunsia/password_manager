class User {
  int? userId;
  String username;
  String fullName;
  String password;

  User({this.userId, required this.username, required this.fullName, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'],
      username: map['username'],
      fullName: map['fullName'],
      password: map['password'],
    );
  }
}