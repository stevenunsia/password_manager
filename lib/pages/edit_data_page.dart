import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/password.dart';
import '../utils/crypto_utils.dart';

class EditPasswordPage extends StatefulWidget {
  final Password password;

  const EditPasswordPage({super.key, required this.password});

  @override
  EditPasswordPageState createState() => EditPasswordPageState();
}

class EditPasswordPageState extends State<EditPasswordPage> {
  late TextEditingController _titleController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.password.title);
    _emailController = TextEditingController(text: widget.password.email);
    _usernameController = TextEditingController(text: widget.password.username);
    _passwordController = TextEditingController(
      text: CryptoUtils.decryptPassword(widget.password.password, widget.password.username),
    );
  }

  Future<void> _updatePassword() async {
    final title = _titleController.text;
    final email = _emailController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (title.isEmpty || email.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email format')),
      );
      return;
    }

    final encryptedPassword = CryptoUtils.encryptPassword(password, username);

    final updatedPassword = Password(
      id: widget.password.id,
      title: title,
      username: username,
      email: email,
      password: encryptedPassword,
    );

    await DatabaseHelper.instance.updatePassword(updatedPassword);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Data Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updatePassword,
              child: Text('Update Data'),
            ),
          ],
        ),
      ),
    );
  }
}