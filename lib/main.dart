import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/registration_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final username = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => HomePage(username: username),
          );
        }
        return null;
      },
    );
  }
}