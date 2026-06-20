// lib/screens/events_admin_tab.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class EventsAdminTab extends StatefulWidget {
  const EventsAdminTab({super.key});

  @override
  State<EventsAdminTab> createState() => _EventsAdminTabState();
}

class _EventsAdminTabState extends State<EventsAdminTab> {
  final List<String> eventTypes = ['Lịch thi', 'Sự kiện', 'Họp phụ huynh'];

  void _showEventDialog({DocumentSnapshot? doc}) {
    bool isEdit = doc != null;
    Map<String, dynamic>? data = isEdit ? doc.data() as Map<String, dynamic> : null;

    TextEditingController titleController = TextEditingController(text: isEdit ? data!['title'] : '');
    TextEditingController dateController = TextEditingController(text: isEdit ? data!['date'] : '');
    TextEditingController descController = TextEditingController(text: isEdit ? data!['description'] : '');
    String selectedType = isEdit ? data!['type'] : eventTypes.first;

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: Text(isEdit ? 'Sửa Sự kiện' : 'Thêm Sự kiện', style: const TextStyle(color: Colors.blue)),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(labelText: 'Loại sự kiện'),
                          items: eventTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (val) { setDialogState(() => selectedType = val!); },
                        ),
                        TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tiêu đề')),
                        TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Ngày (VD: 15/10/2026)')),
                        TextField(controller: descController, decoration: const InputDecoration(labelText: 'Mô tả chi tiết'), maxLines: 3),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () async {
                        Map<String, dynamic> eventData = {
                          'title': titleController.text,
                          'date': dateController.text,
                          'description': descController.text,
                          'type': selectedType,
                        };

                        if (isEdit) {
                          await doc.reference.update(eventData);
                        } else {
                          await FirebaseFirestore.instance.collection('events').add(eventData);
                        }
                        
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Text('Lưu', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              }
          );
        }
    );
  }

  void _deleteEvent(DocumentSnapshot doc) async {
    await doc.reference.delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa sự kiện!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').orderBy('date', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Chưa có sự kiện nào'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final ev = doc.data() as Map<String, dynamic>;
              String type = ev['type'] ?? 'Sự kiện';
              Color iconColor = type == 'Lịch thi' ? Colors.red : (type == 'Sự kiện' ? Colors.blue : Colors.orange);
              IconData icon = type == 'Lịch thi' ? Icons.assignment : (type == 'Sự kiện' ? Icons.event : Icons.groups);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: iconColor.withOpacity(0.2), child: Icon(icon, color: iconColor)),
                  title: Text(ev['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text('Ngày: ${ev['date'] ?? ''}', style: TextStyle(color: iconColor, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(ev['description'] ?? ''),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEventDialog(doc: doc)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteEvent(doc)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
