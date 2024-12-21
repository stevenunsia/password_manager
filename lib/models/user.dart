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
}