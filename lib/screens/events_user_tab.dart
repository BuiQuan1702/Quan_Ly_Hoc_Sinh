import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm Firebase
import '../models/student.dart';

class EventsUserTab extends StatelessWidget {
  const EventsUserTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('date', descending: false) // Sắp xếp theo ngày diễn ra
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Chưa có sự kiện nào sắp tới'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final ev = docs[index].data() as Map<String, dynamic>;
              final type = ev['type'] ?? 'Sự kiện';
              final title = ev['title'] ?? '';
              final date = ev['date'] ?? '';
              final description = ev['description'] ?? '';

              Color iconColor = type == 'Lịch thi' ? Colors.red : (type == 'Sự kiện' ? Colors.green : Colors.orange);
              IconData icon = type == 'Lịch thi' ? Icons.assignment : (type == 'Sự kiện' ? Icons.event : Icons.groups);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Icon(icon, color: iconColor, size: 30),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(5)),
                              child: Text(type.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 5),
                            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Row(children: [const Icon(Icons.calendar_month, size: 14, color: Colors.grey), const SizedBox(width: 5), Text(date, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))]),
                            const SizedBox(height: 8),
                            Text(description, style: const TextStyle(color: Colors.black87)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
