// lib/screens/leave_manage_teacher_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    return FutureBuilder<QuerySnapshot>(
      // 1. Tìm các lớp mà giáo viên này đang phụ trách giảng dạy từ Firestore
      future: FirebaseFirestore.instance
          .collection('timetable')
          .where('teacherName', isEqualTo: widget.teacher.name)
          .get(),
      builder: (context, timetableSnapshot) {
        if (timetableSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final myClasses = timetableSnapshot.data?.docs.map((doc) => doc['className'] as String).toSet().toList() ?? [];

        if (myClasses.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Duyệt đơn xin nghỉ', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue[800], iconTheme: const IconThemeData(color: Colors.white)),
            body: const Center(child: Text('Bạn chưa được phân công dạy lớp nào.', style: TextStyle(color: Colors.grey))),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Duyệt đơn xin nghỉ', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue[800], iconTheme: const IconThemeData(color: Colors.white)),
          body: StreamBuilder<QuerySnapshot>(
            // 2. Lọc ra các đơn xin nghỉ thuộc về học sinh của các lớp đó
            stream: FirebaseFirestore.instance
                .collection('leave_requests')
                .where('className', whereIn: myClasses)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              
              final classRequests = snapshot.data?.docs ?? [];
              // Sắp xếp đơn mới nhất lên đầu (Client side sorting nếu không có index composite trên Firestore)
              final sortedRequests = List.from(classRequests)..sort((a, b) => (b.id).compareTo(a.id));

              if (sortedRequests.isEmpty) {
                return const Center(child: Text('Không có đơn xin nghỉ nào từ lớp bạn phụ trách.', style: TextStyle(color: Colors.grey)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: sortedRequests.length,
                itemBuilder: (context, index) {
                  final doc = sortedRequests[index];
                  final req = doc.data() as Map<String, dynamic>;
                  String status = req['status'] ?? 'Chờ duyệt';
                  Color statusColor = status == 'Đã duyệt' ? Colors.green : (status == 'Từ chối' ? Colors.red : Colors.orange);

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
                              Text('${req['studentName']} - Lớp ${req['className']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Ngày xin nghỉ: ${req['date']}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Lý do: ${req['reason']}', style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),

                          // Nút duyệt chỉ hiện khi đơn ở trạng thái "Chờ duyệt"
                          if (status == 'Chờ duyệt') ...[
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    await doc.reference.update({'status': 'Từ chối'});
                                  },
                                  icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                  label: const Text('Từ chối', style: TextStyle(color: Colors.red)),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  onPressed: () async {
                                    await doc.reference.update({'status': 'Đã duyệt'});
                                  },
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
              );
            },
          ),
        );
      },
    );
  }
}