import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/user.dart';
import '../utils/crypto_utils.dart';
import 'package:logger/logger.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Logger _logger = Logger();

  void _register() async {
    _logger.i("Attempting to register user");
    String username = _usernameController.text;
    String fullName = _fullNameController.text;
    String password = _passwordController.text;

    _logger.i("Username: $username, Full Name: $fullName, Password: $password");

    // Encrypt the password before storing it in the database
    String encryptedPassword = CryptoUtils.encryptPassword(password, username);
    _logger.i("Encrypted Password: $encryptedPassword");

    User newUser = User(username: username, fullName: fullName, password: encryptedPassword);
    await DatabaseHelper.instance.insertUser(newUser);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}