import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/user.dart';
import '../utils/crypto_utils.dart'; // Import CryptoUtils for decryption

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _passwordController;
  
  bool _isPasswordVisible = false;
  bool _isPasswordEditable = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _passwordController = TextEditingController(
      text: CryptoUtils.decryptPassword(widget.user.password, widget.user.username), // Decrypt the password
    );
  }

  Future<void> _updateProfile() async {
    final username = _usernameController.text;
    final fullName = _fullNameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || fullName.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All fields are required')),
        );
      }
      return;
    }

    // Encrypt the password before updating
    final encryptedPassword = CryptoUtils.encryptPassword(password, username);

    final updatedUser = User(
      userId: widget.user.userId,
      username: username,
      fullName: fullName,
      password: encryptedPassword, // Update the password
    );

    await DatabaseHelper.instance.updateUser(updatedUser);

    if (!mounted) return;

    final fetchedUser = await DatabaseHelper.instance.getUser(username);
    if (fetchedUser != null && mounted) {
      Navigator.pop(context, fetchedUser);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Username'),
              subtitle: TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                readOnly: true, // Lock the username field
              ),
            ),
            ListTile(
              title: Text('Full Name'),
              subtitle: TextField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
            ),
            ListTile(
              title: Text('Password'),
              subtitle: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: !_isPasswordVisible,
                      readOnly: !_isPasswordEditable, // Lock the password field initially
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        _isPasswordEditable = !_isPasswordEditable;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _updateProfile();
              },
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}