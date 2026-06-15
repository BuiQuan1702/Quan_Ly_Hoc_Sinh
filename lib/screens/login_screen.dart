// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../models/student.dart';
import 'user_screen.dart';
import 'admin_screen.dart';
import 'teacher_screen.dart'; // IMPORT MÀN HÌNH GIÁO VIÊN MỚI

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Biến lưu trữ vai trò đang chọn ở form chính: 'Học sinh' hoặc 'Giáo viên'
  String _selectedRole = 'Học sinh';

  void _login() {
    String id = _idController.text;
    String password = _passwordController.text;

    if (_selectedRole == 'Học sinh') {
      try {
        Student student = mockStudents.firstWhere((s) => s.id == id && s.password == password);
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserScreen(loggedInStudent: student)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sai Mã học sinh hoặc mật khẩu!'), backgroundColor: Colors.red));
      }
    } else if (_selectedRole == 'Giáo viên') {
      try {
        Teacher teacher = mockTeachers.firstWhere((t) => t.id == id && t.password == password);
        Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherScreen(loggedInTeacher: teacher)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sai Mã giáo viên hoặc mật khẩu!'), backgroundColor: Colors.red));
      }
    }
  }

  // Hộp thoại đăng nhập ẩn dành riêng cho System Admin (Hiệu trưởng/Giáo vụ)
  void _showSystemAdminDialog() {
    TextEditingController adminIdController = TextEditingController();
    TextEditingController adminPassController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Đăng nhập Quản trị Hệ thống', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Khu vực này chỉ dành cho Ban giám hiệu/Giáo vụ.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 10),
                TextField(controller: adminIdController, decoration: const InputDecoration(labelText: 'Tài khoản (VD: admin)')),
                TextField(controller: adminPassController, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu (VD: admin123)')),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  if (adminIdController.text == 'admin' && adminPassController.text == 'admin123') {
                    Navigator.pop(context); // Đóng dialog
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sai thông tin Quản trị!'), backgroundColor: Colors.red));
                  }
                },
                child: const Text('Truy cập', style: TextStyle(color: Colors.white)),
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage('assets/background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 100, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text('HỆ THỐNG QUẢN LÝ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                  const Text('Dành cho Giáo viên & Học sinh', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))]),
                    child: Column(
                      children: [
                        // Nâng cấp: Dropdown chọn vai trò
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(labelText: 'Bạn là ai?', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge)),
                          items: ['Học sinh', 'Giáo viên'].map((role) => DropdownMenuItem(value: role, child: Text(role, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                          onChanged: (value) => setState(() => _selectedRole = value!),
                        ),
                        const SizedBox(height: 15),
                        TextField(controller: _idController, decoration: InputDecoration(labelText: _selectedRole == 'Học sinh' ? 'Mã Học sinh (VD: HS001)' : 'Mã Giáo viên (VD: GV001)', prefixIcon: const Icon(Icons.person), border: const OutlineInputBorder())),
                        const SizedBox(height: 15),
                        TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu', prefixIcon: const Icon(Icons.lock), border: const OutlineInputBorder())),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: _selectedRole == 'Học sinh' ? Colors.green : Colors.blue, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          onPressed: _login,
                          child: const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  // Nút dành riêng cho Quản trị viên hệ thống
                  TextButton.icon(
                    onPressed: _showSystemAdminDialog,
                    icon: const Icon(Icons.admin_panel_settings, color: Colors.white54),
                    label: const Text('Truy cập Quản trị viên (Admin)', style: TextStyle(color: Colors.white54, decoration: TextDecoration.underline)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}