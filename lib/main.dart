import 'package:flutter/material.dart';
import 'screens/intro_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    throw Exception('Error loading .env file: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoConnect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IntroScreen(),
    );
  }
}
