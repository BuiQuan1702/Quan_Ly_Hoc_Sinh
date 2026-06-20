// lib/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class EditProfileScreen extends StatefulWidget {
  final Student student;

  const EditProfileScreen({super.key, required this.student});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _classController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.student.id);
    _nameController = TextEditingController(text: widget.student.name);
    _classController = TextEditingController(text: widget.student.className);
    _passwordController = TextEditingController(text: widget.student.password);
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _classController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ & Thẻ Học Sinh', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
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
            // ================= THẺ HỌC SINH ĐIỆN TỬ =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.teal.shade400],
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
                  // Cột trái: Ảnh đại diện và Mã QR
                  Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 50, color: Colors.green),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // Mã QR giả lập
                        child: const Icon(Icons.qr_code_2, size: 60, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Cột phải: Thông tin thẻ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('THẺ HỌC SINH', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        const SizedBox(height: 5),
                        Text(widget.student.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const Divider(color: Colors.white54),
                        const SizedBox(height: 5),
                        Text('Lớp: ${widget.student.className}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 5),
                        Text('Mã HS: ${widget.student.id}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 15),
                        const Text('Trạng thái: Đang theo học', style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
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
            _buildProfileField('Mã Học Sinh:', _idController, isReadOnly: true),
            _buildProfileField('Họ và Tên:', _nameController),
            _buildProfileField('Lớp:', _classController, isReadOnly: true), // Lớp không nên tự sửa
            _buildProfileField('Mật khẩu:', _passwordController, isPassword: true),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // Cập nhật lên Firestore
                    var snapshot = await FirebaseFirestore.instance
                        .collection('students')
                        .where('id', isEqualTo: widget.student.id)
                        .get();

                    if (snapshot.docs.isNotEmpty) {
                      await snapshot.docs.first.reference.update({
                        'name': _nameController.text,
                        'password': _passwordController.text,
                      });

                      // Cập nhật object local để UI quay về hiển thị đúng (nếu cần)
                      setState(() {
                        widget.student.name = _nameController.text;
                        widget.student.password = _passwordController.text;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hồ sơ đã được cập nhật!'), backgroundColor: Colors.green),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không tìm thấy học sinh trên hệ thống!'), backgroundColor: Colors.redAccent),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi cập nhật: $e'), backgroundColor: Colors.redAccent),
                    );
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