// lib/screens/leave_request_student_screen.dart
import 'package:flutter/material.dart';
import '../../../models/student.dart';

class LeaveRequestStudentScreen extends StatefulWidget {
  final Student student;
  const LeaveRequestStudentScreen({super.key, required this.student});

  @override
  State<LeaveRequestStudentScreen> createState() => _LeaveRequestStudentScreenState();
}

class _LeaveRequestStudentScreenState extends State<LeaveRequestStudentScreen> {
  void _showCreateRequestDialog() {
    TextEditingController reasonController = TextEditingController();
    DateTime chosenDate = DateTime.now();
    TextEditingController dateController = TextEditingController(
        text: "${chosenDate.day.toString().padLeft(2, '0')}/${chosenDate.month.toString().padLeft(2, '0')}/${chosenDate.year}");

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Viết đơn xin nghỉ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController, readOnly: true,
                decoration: const InputDecoration(labelText: 'Ngày nghỉ', suffixIcon: Icon(Icons.calendar_today, color: Colors.green)),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                      context: context, initialDate: chosenDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
                  if (picked != null) {
                    setDialogState(() {
                      chosenDate = picked;
                      dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                    });
                  }
                },
              ),
              const SizedBox(height: 15),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Lý do chi tiết', border: OutlineInputBorder()),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập lý do!'), backgroundColor: Colors.red));
                  return;
                }
                setState(() {
                  mockLeaveRequests.add(LeaveRequest(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    studentId: widget.student.id, studentName: widget.student.name,
                    className: widget.student.className, date: dateController.text, reason: reasonController.text,
                  ));
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi đơn thành công!'), backgroundColor: Colors.green));
              },
              child: const Text('Gửi đơn', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Chỉ lấy các đơn xin nghỉ của chính học sinh này
    final myRequests = mockLeaveRequests.where((req) => req.studentId == widget.student.id).toList()..sort((a, b) => b.id.compareTo(a.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Đơn xin nghỉ phép', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green, iconTheme: const IconThemeData(color: Colors.white)),
      body: myRequests.isEmpty
          ? const Center(child: Text('Bạn chưa có đơn xin nghỉ nào.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: myRequests.length,
        itemBuilder: (context, index) {
          final req = myRequests[index];
          Color statusColor = req.status == 'Đã duyệt' ? Colors.green : (req.status == 'Từ chối' ? Colors.red : Colors.orange);
          return Card(
            elevation: 2, margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(Icons.assignment, color: statusColor, size: 30),
              title: Text('Ngày nghỉ: ${req.date}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Lý do: ${req.reason}\nTrạng thái: ${req.status}', style: const TextStyle(height: 1.5)),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateRequestDialog, backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white), label: const Text('Viết đơn', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}