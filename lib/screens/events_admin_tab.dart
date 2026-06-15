// lib/screens/events_admin_tab.dart
import 'package:flutter/material.dart';
import '../models/student.dart';

class EventsAdminTab extends StatefulWidget {
  const EventsAdminTab({super.key});

  @override
  State<EventsAdminTab> createState() => _EventsAdminTabState();
}

class _EventsAdminTabState extends State<EventsAdminTab> {
  final List<String> eventTypes = ['Lịch thi', 'Sự kiện', 'Họp phụ huynh'];

  void _showEventDialog({SchoolEvent? event, int? index}) {
    bool isEdit = event != null;
    TextEditingController titleController = TextEditingController(text: isEdit ? event.title : '');
    TextEditingController dateController = TextEditingController(text: isEdit ? event.date : '');
    TextEditingController descController = TextEditingController(text: isEdit ? event.description : '');
    String selectedType = isEdit ? event.type : eventTypes.first;

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
                      onPressed: () {
                        setState(() {
                          if (isEdit) {
                            event.title = titleController.text;
                            event.date = dateController.text;
                            event.description = descController.text;
                            event.type = selectedType;
                          } else {
                            mockEvents.add(SchoolEvent(
                                id: DateTime.now().toString(),
                                title: titleController.text, date: dateController.text,
                                description: descController.text, type: selectedType
                            ));
                          }
                        });
                        Navigator.pop(context);
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

  void _deleteEvent(int index) {
    setState(() { mockEvents.removeAt(index); });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa sự kiện!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mockEvents.isEmpty
          ? const Center(child: Text('Chưa có sự kiện nào'))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: mockEvents.length,
        itemBuilder: (context, index) {
          final ev = mockEvents[index];
          Color iconColor = ev.type == 'Lịch thi' ? Colors.red : (ev.type == 'Sự kiện' ? Colors.blue : Colors.orange);
          IconData icon = ev.type == 'Lịch thi' ? Icons.assignment : (ev.type == 'Sự kiện' ? Icons.event : Icons.groups);

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: iconColor.withOpacity(0.2), child: Icon(icon, color: iconColor)),
              title: Text(ev.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text('Ngày: ${ev.date}', style: TextStyle(color: iconColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(ev.description),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEventDialog(event: ev, index: index)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteEvent(index)),
                ],
              ),
            ),
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