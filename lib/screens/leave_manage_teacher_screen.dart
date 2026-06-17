// lib/screens/leave_manage_teacher_screen.dart
import 'package:flutter/material.dart';
import '../models/student.dart';

class LeaveManageTeacherScreen extends StatefulWidget {
  final Teacher teacher;
  const LeaveManageTeacherScreen({super.key, required this.teacher});

  @override
  State<LeaveManageTeacherScreen> createState() => _LeaveManageTeacherScreenState();
}

class _LeaveManageTeacherScreenState extends State<LeaveManageTeacherScreen> {
  @override
  Widget build(BuildContext context) {
    // 1. Tìm các lớp mà giáo viên này đang phụ trách giảng dạy
    final myClasses = mockTimetable.where((l) => l.teacherName == widget.teacher.name).map((l) => l.className).toSet().toList();
    // 2. Lọc ra các đơn xin nghỉ thuộc về học sinh của các lớp đó
    final classRequests = mockLeaveRequests.where((req) => myClasses.contains(req.className)).toList()..sort((a, b) => b.id.compareTo(a.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Duyệt đơn xin nghỉ', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue[800], iconTheme: const IconThemeData(color: Colors.white)),
      body: classRequests.isEmpty
          ? const Center(child: Text('Không có đơn xin nghỉ nào từ lớp bạn phụ trách.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: classRequests.length,
        itemBuilder: (context, index) {
          final req = classRequests[index];
          Color statusColor = req.status == 'Đã duyệt' ? Colors.green : (req.status == 'Từ chối' ? Colors.red : Colors.orange);

          return Card(
            elevation: 3, margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${req.studentName} - Lớp ${req.className}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(req.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Ngày xin nghỉ: ${req.date}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Lý do: ${req.reason}', style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),

                  // Nút duyệt chỉ hiện khi đơn ở trạng thái "Chờ duyệt"
                  if (req.status == 'Chờ duyệt') ...[
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => setState(() => req.status = 'Từ chối'),
                          icon: const Icon(Icons.close, color: Colors.red, size: 18),
                          label: const Text('Từ chối', style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () => setState(() => req.status = 'Đã duyệt'),
                          icon: const Icon(Icons.check, color: Colors.white, size: 18),
                          label: const Text('Duyệt đơn', style: TextStyle(color: Colors.white)),
                        )
                      ],
                    )
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}