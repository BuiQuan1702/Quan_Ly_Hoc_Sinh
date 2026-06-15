// lib/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import '../models/student.dart'; // Import model học sinh

class EditProfileScreen extends StatefulWidget {
  final Student student; // Khai báo biến để nhận dữ liệu học sinh

  // Yêu cầu phải truyền student vào khi mở màn hình này
  const EditProfileScreen({super.key, required this.student});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Khai báo các controller
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _classController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller và điền sẵn thông tin của học sinh đang đăng nhập
    _idController = TextEditingController(text: widget.student.id);
    _nameController = TextEditingController(text: widget.student.name);
    _classController = TextEditingController(text: widget.student.className);
    _passwordController = TextEditingController(text: widget.student.password);
  }

  @override
  void dispose() {
    // Dọn dẹp bộ nhớ khi đóng màn hình
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
        title: const Text('Hồ sơ Sinh Viên', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Phần hiển thị văn bản chào
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 20, color: Colors.black),
                children: <TextSpan>[
                  const TextSpan(text: 'Xin chào: '),
                  TextSpan(
                    text: widget.student.name, // Lấy tên thật của học sinh
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Hình đại diện hình tròn
            Stack(
              alignment: Alignment.center,
              children: [
                const CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, size: 80, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Các trường thông tin chi tiết (Đã sửa lại khớp với model Student)
            _buildProfileField('Mã Học Sinh:', _idController, isReadOnly: true), // Mã HS thường không được đổi
            _buildProfileField('Họ và Tên:', _nameController),
            _buildProfileField('Lớp:', _classController),
            _buildProfileField('Mật khẩu:', _passwordController, isPassword: true),

            const SizedBox(height: 40),

            // Nút hành động
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Cập nhật lại thông tin vào đối tượng student
                  setState(() {
                    widget.student.name = _nameController.text;
                    widget.student.className = _classController.text;
                    widget.student.password = _passwordController.text;
                  });

                  // Hiển thị thông báo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hồ sơ đã được cập nhật!'), backgroundColor: Colors.green),
                  );

                  // Đóng màn hình chỉnh sửa sau khi lưu
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Nút lưu màu đỏ như thiết kế
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

  // Hàm thiết kế giao diện cho từng ô nhập liệu
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
          readOnly: isReadOnly, // Có cho phép chỉnh sửa hay không
          obscureText: isPassword, // Có ẩn chữ thành dấu chấm không
          decoration: InputDecoration(
            filled: isReadOnly,
            fillColor: isReadOnly ? Colors.grey[200] : Colors.white, // Làm xám ô nếu không được sửa
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