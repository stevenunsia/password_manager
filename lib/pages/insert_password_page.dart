import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/password.dart';

class InsertPasswordPage extends StatefulWidget {
  const InsertPasswordPage({super.key});

  @override
  InsertPasswordPageState createState() => InsertPasswordPageState();
}

class InsertPasswordPageState extends State<InsertPasswordPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _insertPassword() async {
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

    final newPassword = Password(
      title: title,
      email: email,
      username: username,
      password: password,
    );

    await DatabaseHelper.instance.insertPassword(newPassword);

    if (!mounted) return;

    Navigator.pop(context, true); // Indicate success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Nama Aplikasi'),
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
              onPressed: _insertPassword,
              child: Text('Simpan Data'),
            ),
          ],
        ),
      ),
    );
  }
}