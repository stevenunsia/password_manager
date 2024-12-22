class Password {
  int? id;
  String title;
  String email;
  String username;
  String password;

  Password({this.id, required this.title, required this.email, required this.username, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'email': email,
      'username': username,
      'password': password,
    };
  }

  factory Password.fromMap(Map<String, dynamic> map) {
    return Password(
      id: map['id'],
      title: map['title'],
      email: map['email'],
      username: map['username'],
      password: map['password'],
    );
  }
}