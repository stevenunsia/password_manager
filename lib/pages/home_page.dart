import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/password.dart';
import 'edit_data_page.dart'; // Import the EditDataPage
import 'insert_data_page.dart'; // Import the InsertDataPage
import 'profile_page.dart';
import '../utils/crypto_utils.dart'; // Import CryptoUtils for decryption

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Password> _passwords = [];
  Map<int, bool> _showPasswords = {}; // Track which passwords are shown

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    final passwords = await DatabaseHelper.instance.getPasswordsByUsername(widget.username);
    if (mounted) {
      setState(() {
        _passwords = passwords;
        _showPasswords = {for (var password in passwords) password.id!: false}; // Initialize all passwords as hidden
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = <Widget>[
      _buildPasswordPage(),
      ProfilePage(username: widget.username),
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Password Manager")),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'Password',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildPasswordPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _passwords.length,
              itemBuilder: (context, index) {
                final password = _passwords[index];
                final isPasswordVisible = _showPasswords[password.id] ?? false;
                final decryptedPassword = isPasswordVisible
                    ? CryptoUtils.decryptPassword(password.password, password.username)
                    : '********';

                return ListTile(
                  title: Text(password.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${password.email}'),
                      Text('Username: ${password.username}'),
                      Text('Password: $decryptedPassword'), // Show decrypted password if visible
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _showPasswords[password.id!] = !isPasswordVisible;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await DatabaseHelper.instance.deletePassword(password.id!);
                          _loadPasswords();
                        },
                      ),
                    ],
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPasswordPage(password: password), // Pass the correct password object
                      ),
                    );
                    if (result == true && mounted) {
                      _loadPasswords();
                    }
                  },
                );
              },
            ),
          ),
          FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InsertDataPage()), // Use the correct class name
              );
              if (result == true && mounted) {
                _loadPasswords();
              }
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}