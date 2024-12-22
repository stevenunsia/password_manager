import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/user.dart';
import 'edit_profile_page.dart'; // Import the EditProfilePage
import 'login_page.dart'; // Import the LoginPage

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late Future<User?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  Future<User?> _loadUser() async {
    return await DatabaseHelper.instance.getUser(widget.username);
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load user data: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No user data available'));
          } else {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      ListTile(
                        title: Text('Username'),
                        subtitle: Text(user.username),
                      ),
                      ListTile(
                        title: Text('Full Name'),
                        subtitle: Text(user.fullName),
                      ),
                      ListTile(
                        title: Text('Password'),
                        subtitle: Text('********'), // Masked password
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(user: user),
                            ),
                          );
                          if (result != null && result is User) {
                            setState(() {
                              _userFuture = Future.value(result);
                            });
                          }
                        },
                        child: Text('Edit Profile'),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _logout,
                    child: Text('Logout'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}