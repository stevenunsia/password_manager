import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/password.dart';
import 'insert_password_page.dart'; // Import the InsertPasswordPage
import 'edit_password_page.dart'; // Import the EditPasswordPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Password> _passwords = [];

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    final passwords = await DatabaseHelper.instance.getPasswords();
    setState(() {
      _passwords = passwords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Password Manager")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _passwords.length,
                itemBuilder: (context, index) {
                  final password = _passwords[index];
                  return ListTile(
                    title: Text(password.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${password.email}'),
                        Text('Username: ${password.username}'),
                        Text('Password: ${password.password}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await DatabaseHelper.instance.deletePassword(password.id!);
                        _loadPasswords();
                      },
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPasswordPage(password: password),
                        ),
                      );
                      if (result == true) {
                        _loadPasswords();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InsertPasswordPage()),
          );
          if (result == true) {
            _loadPasswords();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}