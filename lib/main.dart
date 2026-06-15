// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Import màn hình login

void main() {
  runApp(const StudentManagerApp());
}

class StudentManagerApp extends StatelessWidget {
  const StudentManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản Lý Học Sinh',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Màn hình khởi chạy đầu tiên là LoginScreen
      home: const LoginScreen(),
    );
  }
}