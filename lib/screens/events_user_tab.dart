// lib/screens/events_user_tab.dart
import 'package:flutter/material.dart';
import '../models/student.dart';

class EventsUserTab extends StatelessWidget {
  const EventsUserTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mockEvents.isEmpty
          ? const Center(child: Text('Chưa có sự kiện nào sắp tới'))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: mockEvents.length,
        itemBuilder: (context, index) {
          final ev = mockEvents[index];
          Color iconColor = ev.type == 'Lịch thi' ? Colors.red : (ev.type == 'Sự kiện' ? Colors.green : Colors.orange);
          IconData icon = ev.type == 'Lịch thi' ? Icons.assignment : (ev.type == 'Sự kiện' ? Icons.event : Icons.groups);

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
                          child: Text(ev.type.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 5),
                        Text(ev.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Row(children: [const Icon(Icons.calendar_month, size: 14, color: Colors.grey), const SizedBox(width: 5), Text(ev.date, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 8),
                        Text(ev.description, style: const TextStyle(color: Colors.black87)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}