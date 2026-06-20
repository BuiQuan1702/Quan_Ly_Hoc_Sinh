// lib/screens/teacher_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart'; // Import để lấy model Teacher

class TeacherProfileScreen extends StatefulWidget {
  final Teacher teacher;

  const TeacherProfileScreen({super.key, required this.teacher});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.teacher.id);
    _nameController = TextEditingController(text: widget.teacher.name);
    _phoneController = TextEditingController(text: widget.teacher.phone);
    _passwordController = TextEditingController(text: widget.teacher.password);
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ Giáo viên', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ================= THẺ GIÁO VIÊN ĐIỆN TỬ =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.lightBlue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.work, size: 40, color: Colors.blue),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.qr_code_2, size: 60, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('THẺ CÁN BỘ / GIÁO VIÊN', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 5),
                        Text(widget.teacher.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const Divider(color: Colors.white54),
                        const SizedBox(height: 5),
                        Text('Mã GV: ${widget.teacher.id}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 5),
                        Text('SĐT: ${widget.teacher.phone}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 15),
                        const Text('Trạng thái: Đang công tác', style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text('CẬP NHẬT THÔNG TIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 15),

            // ================= FORM CHỈNH SỬA =================
            _buildProfileField('Mã Giáo Viên:', _idController, isReadOnly: true), // Mã không được sửa
            _buildProfileField('Họ và Tên:', _nameController),
            _buildProfileField('Số điện thoại:', _phoneController),
            _buildProfileField('Mật khẩu:', _passwordController, isPassword: true),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // Cập nhật lên Firestore bằng ID trực tiếp (document ID chính là Mã GV)
                    await FirebaseFirestore.instance
                        .collection('teachers')
                        .doc(widget.teacher.id)
                        .update({
                      'name': _nameController.text,
                      'phone': _phoneController.text,
                      'password': _passwordController.text,
                    });

                    // Cập nhật dữ liệu vào model local để UI hiển thị ngay lập tức
                    setState(() {
                      widget.teacher.name = _nameController.text;
                      widget.teacher.phone = _phoneController.text;
                      widget.teacher.password = _passwordController.text;
                    });

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hồ sơ Giáo viên đã được cập nhật!'), backgroundColor: Colors.blue),
                      );
                      Navigator.pop(context, true); // Trả về true để màn hình trước biết đã cập nhật
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi cập nhật: $e'), backgroundColor: Colors.redAccent),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, {bool isReadOnly = false, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          obscureText: isPassword,
          decoration: InputDecoration(
            filled: isReadOnly,
            fillColor: isReadOnly ? Colors.grey[200] : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}