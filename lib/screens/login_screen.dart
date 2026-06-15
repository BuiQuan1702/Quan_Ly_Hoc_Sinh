// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../models/student.dart'; // Import để lấy danh sách học sinh
import 'admin_screen.dart';
import 'user_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Bộ điều khiển để lấy dữ liệu từ ô nhập text của học sinh
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Hàm xử lý đăng nhập cho Học sinh (giữ nguyên như cũ)
  void _loginAsStudent() {
    String inputId = _idController.text.trim();
    String inputPassword = _passwordController.text.trim();

    Student? matchedStudent;

    for (var student in mockStudents) {
      if (student.id == inputId && student.password == inputPassword) {
        matchedStudent = student;
        break;
      }
    }

    if (matchedStudent != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserScreen(loggedInStudent: matchedStudent!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sai mã học sinh hoặc mật khẩu!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- THÊM MỚI: Hàm hiển thị hộp thoại đăng nhập cho Admin ---
  void _showAdminLoginDialog() {
    TextEditingController adminIdController = TextEditingController();
    TextEditingController adminPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đăng nhập Quản trị viên', style: TextStyle(color: Colors.blue)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: adminIdController,
                decoration: const InputDecoration(
                  labelText: 'Tài khoản Admin',
                  prefixIcon: Icon(Icons.admin_panel_settings),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: adminPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu Admin',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy')
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                // Kiểm tra tài khoản và mật khẩu cứng của Admin
                if (adminIdController.text == 'admin' && adminPasswordController.text == 'admin123') {
                  Navigator.pop(context); // Đóng hộp thoại
                  // Chuyển sang màn hình Admin
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminScreen()));
                } else {
                  // Báo lỗi nếu sai
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sai tài khoản hoặc mật khẩu Admin!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Đăng nhập', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage(
              'assets/background.jpg',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 80, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  'HỆ THỐNG QUẢN LÝ\nHỌC SINH',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 40),

                // Form đăng nhập của học sinh
                TextField(
                  controller: _idController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mã Học Sinh',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white70),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white70),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _loginAsStudent,
                    child: const Text('ĐĂNG NHẬP HỌC SINH', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: Colors.white54),
                const SizedBox(height: 20),

                // Nút đăng nhập Admin đã được cập nhật sự kiện
                TextButton(
                  onPressed: _showAdminLoginDialog, // Gọi hàm mở hộp thoại đăng nhập Admin
                  child: const Text('Đăng nhập với tư cách Giáo viên (Admin)', style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}