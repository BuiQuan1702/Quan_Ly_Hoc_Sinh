import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm Firebase
import '../../../models/student.dart';

class LeaveRequestStudentScreen extends StatefulWidget {
  final Student student;
  const LeaveRequestStudentScreen({super.key, required this.student});

  @override
  State<LeaveRequestStudentScreen> createState() => _LeaveRequestStudentScreenState();
}

class _LeaveRequestStudentScreenState extends State<LeaveRequestStudentScreen> {
  // Hàm gửi đơn lên Firebase
  Future<void> _submitRequest(String date, String reason, String className) async {
    try {
      await FirebaseFirestore.instance.collection('leave_requests').add({
        'studentId': widget.student.id,
        'studentName': widget.student.name,
        'className': className,
        'date': date,
        'reason': reason,
        'status': 'Chờ duyệt',
        'createdAt': FieldValue.serverTimestamp(), // Để sắp xếp
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi đơn thành công!'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    }
  }

  void _showCreateRequestDialog() {
    TextEditingController reasonController = TextEditingController();
    DateTime chosenDate = DateTime.now();
    TextEditingController dateController = TextEditingController(
        text: "${chosenDate.day.toString().padLeft(2, '0')}/${chosenDate.month.toString().padLeft(2, '0')}/${chosenDate.year}");
    
    String? selectedClass = widget.student.classNames.isNotEmpty ? widget.student.classNames.first : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Viết đơn xin nghỉ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedClass,
                  decoration: const InputDecoration(labelText: 'Chọn lớp nghỉ', border: OutlineInputBorder()),
                  items: widget.student.classNames.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setDialogState(() => selectedClass = val),
                ),
                const SizedBox(height: 15),
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
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                if (selectedClass == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn lớp!'), backgroundColor: Colors.red));
                  return;
                }
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập lý do!'), backgroundColor: Colors.red));
                  return;
                }
                _submitRequest(dateController.text, reasonController.text, selectedClass!);
                Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Đơn xin nghỉ phép', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green, iconTheme: const IconThemeData(color: Colors.white)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leave_requests')
            .where('studentId', isEqualTo: widget.student.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Bạn chưa có đơn xin nghỉ nào.', style: TextStyle(color: Colors.grey)));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final req = docs[index].data() as Map<String, dynamic>;
              final date = req['date'] ?? '';
              final reason = req['reason'] ?? '';
              final status = req['status'] ?? 'Chờ duyệt';
              final className = req['className'] ?? 'N/A';
              
              Color statusColor = status == 'Đã duyệt' ? Colors.green : (status == 'Từ chối' ? Colors.red : Colors.orange);
              
              return Card(
                elevation: 2, margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(Icons.assignment, color: statusColor, size: 30),
                  title: Text('Ngày nghỉ: $date', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lớp: $className', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                      Text('Lý do: $reason', style: const TextStyle(height: 1.2)),
                      Text('Trạng thái: $status', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
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
