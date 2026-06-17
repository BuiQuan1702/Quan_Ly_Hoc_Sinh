// lib/screens/login_screen.dart
import 'dart:ui'; // Bắt buộc phải có để dùng hiệu ứng Kính mờ (BackdropFilter)
import 'package:flutter/material.dart';
import '../models/student.dart';
import 'user_screen.dart';
import 'admin_screen.dart';
import 'teacher_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Học sinh';

  void _login() {
    String id = _idController.text.trim();
    String password = _passwordController.text.trim();

    if (_selectedRole == 'Học sinh') {
      try {
        Student student = mockStudents.firstWhere((s) => s.id == id && s.password == password);
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserScreen(loggedInStudent: student)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sai Mã học sinh hoặc mật khẩu!'), backgroundColor: Colors.redAccent));
      }
    } else if (_selectedRole == 'Giáo viên') {
      try {
        Teacher teacher = mockTeachers.firstWhere((t) => t.id == id && t.password == password);
        Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherScreen(loggedInTeacher: teacher)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sai Mã giáo viên hoặc mật khẩu!'), backgroundColor: Colors.redAccent));
      }
    }
  }

  // Hộp thoại đăng nhập dành riêng cho Quản trị viên hệ thống (Được bo góc và làm đẹp lại)
  void _showSystemAdminDialog() {
    TextEditingController adminIdController = TextEditingController();
    TextEditingController adminPassController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Quản trị Hệ thống', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 22)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Khu vực này chỉ dành cho Ban giám hiệu/Giáo vụ.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 20),
                TextField(
                    controller: adminIdController,
                    decoration: InputDecoration(
                      labelText: 'Tài khoản',
                      prefixIcon: const Icon(Icons.shield),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    )
                ),
                const SizedBox(height: 15),
                TextField(
                    controller: adminPassController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    )
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                ),
                onPressed: () {
                  if (adminIdController.text == 'admin' && adminPassController.text == 'admin123') {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminScreen()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sai thông tin Quản trị!'), backgroundColor: Colors.redAccent));
                  }
                },
                child: const Text('Truy cập', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. LỚP NỀN: Ảnh nền được giữ nguyên nhưng thêm lớp màu tối (Overlay) đè lên
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), // Ảnh lấy từ máy của bạn
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.4), // Phủ lớp đen mờ giúp chữ nổi bật hơn
          ),

          // 2. LỚP NỘI DUNG CHÍNH
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- Vùng Tiêu đề & Logo ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    ),
                    child: const Icon(Icons.school, size: 80, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                      'HỆ THỐNG QUẢN LÝ',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))]
                      )
                  ),
                  const Text(
                      'Cổng thông tin Giáo viên & Học sinh',
                      style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500)
                  ),
                  const SizedBox(height: 40),

                  // --- Vùng Nhập liệu (Hiệu ứng Kính mờ - Glassmorphism) ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Làm mờ cảnh vật phía sau khối thẻ
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
                            ]
                        ),
                        child: Column(
                          children: [
                            // 1. Nút Chọn Vai trò (Dropdown xịn xò)
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.blueAccent),
                              decoration: InputDecoration(
                                labelText: 'Bạn là ai?',
                                labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                prefixIcon: const Icon(Icons.badge, color: Colors.blueAccent),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: Colors.blueAccent.withOpacity(0.05),
                              ),
                              items: ['Học sinh', 'Giáo viên'].map((role) => DropdownMenuItem(value: role, child: Text(role, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))).toList(),
                              onChanged: (value) => setState(() => _selectedRole = value!),
                            ),
                            const SizedBox(height: 20),

                            // 2. Ô nhập Mã ID
                            TextField(
                                controller: _idController,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  labelText: _selectedRole == 'Học sinh' ? 'Mã Học sinh (VD: HS001)' : 'Mã Giáo viên (VD: GV001)',
                                  prefixIcon: const Icon(Icons.person_outline, color: Colors.blueAccent),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.1),
                                )
                            ),
                            const SizedBox(height: 15),

                            // 3. Ô nhập Mật khẩu
                            TextField(
                                controller: _passwordController,
                                obscureText: true,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  labelText: 'Mật khẩu',
                                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.blueAccent),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor: Colors.grey.withOpacity(0.1),
                                )
                            ),
                            const SizedBox(height: 30),

                            // 4. Nút Đăng nhập Gradient
                            Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    // Đổi màu Gradient tự động: Xanh lá cho Học sinh, Xanh dương cho Giáo viên
                                    colors: _selectedRole == 'Học sinh'
                                        ? [Colors.greenAccent.shade700, Colors.teal]
                                        : [Colors.blueAccent, Colors.indigo],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: (_selectedRole == 'Học sinh' ? Colors.green : Colors.blue).withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8)
                                    )
                                  ]
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent, // Nền trong suốt để lộ màu Gradient phía sau
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: _login,
                                child: const Text('ĐĂNG NHẬP', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- Vùng Nút Admin ẩn ---
                  TextButton.icon(
                    onPressed: _showSystemAdminDialog,
                    icon: const Icon(Icons.admin_panel_settings, color: Colors.white70),
                    label: const Text('Khu vực Quản trị viên (Admin)', style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline, fontWeight: FontWeight.w600)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}