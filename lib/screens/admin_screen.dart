// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'events_admin_tab.dart'; 

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;
  final List<String> daysOfWeek = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];

  // ================= DIALOGS =================

  void _showAddNewsDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng Thông Báo Mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tiêu đề')),
            const SizedBox(height: 10),
            TextField(controller: contentController, maxLines: 3, decoration: const InputDecoration(labelText: 'Nội dung')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;
              await FirebaseFirestore.instance.collection('notifications').add({
                'title': titleController.text,
                'content': contentController.text,
                'date': DateTime.now().toString().substring(0, 16),
              });
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Đăng tin'),
          )
        ],
      ),
    );
  }

  void _showAddTeacherDialog({DocumentSnapshot? doc}) {
    bool isEdit = doc != null;
    Map<String, dynamic>? data = isEdit ? doc.data() as Map<String, dynamic> : null;

    final idController = TextEditingController(text: isEdit ? data!['id'] : '');
    final nameController = TextEditingController(text: isEdit ? data!['name'] : '');
    final phoneController = TextEditingController(text: isEdit ? data!['phone'] : '');
    final passwordController = TextEditingController(text: isEdit ? data!['password'] : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Sửa Giáo Viên' : 'Thêm Giáo Viên'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã GV'), readOnly: isEdit),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ Tên')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(onPressed: () async {
            if (idController.text.isEmpty) return;
            final teacherData = {
              'id': idController.text,
              'name': nameController.text,
              'phone': phoneController.text,
              'password': passwordController.text,
            };
            if (isEdit) {
              await doc.reference.update(teacherData);
            } else {
              await FirebaseFirestore.instance.collection('teachers').doc(idController.text).set(teacherData);
            }
            if (mounted) Navigator.pop(context);
          }, child: const Text('Lưu'))
        ],
      ),
    );
  }

  void _showAddStudentDialog({DocumentSnapshot? doc}) {
    bool isEdit = doc != null;
    Map<String, dynamic>? data = isEdit ? doc.data() as Map<String, dynamic> : null;

    final idController = TextEditingController(text: isEdit ? data!['id'] : '');
    final nameController = TextEditingController(text: isEdit ? data!['name'] : '');
    final classController = TextEditingController(text: isEdit ? data!['className'] : '');
    final passwordController = TextEditingController(text: isEdit ? data!['password'] : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Sửa Học Sinh' : 'Thêm Học Sinh'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã HS'), readOnly: isEdit),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ Tên')),
            TextField(controller: classController, decoration: const InputDecoration(labelText: 'Lớp')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(onPressed: () async {
            if (idController.text.isEmpty) return;
            // Ép kiểu literal Map<String, dynamic> để tránh lỗi type inference
            final studentData = <String, dynamic>{
              'id': idController.text,
              'name': nameController.text,
              'className': classController.text,
              'password': passwordController.text,
            };
            
            if (isEdit) {
              await doc.reference.update(studentData);
            } else {
              studentData['grades'] = <String, dynamic>{};
              await FirebaseFirestore.instance.collection('students').doc(idController.text).set(studentData);
            }
            if (mounted) Navigator.pop(context);
          }, child: const Text('Lưu'))
        ],
      ),
    );
  }

  void _showAddTimetableDialog({DocumentSnapshot? doc}) {
    bool isEdit = doc != null;
    Map<String, dynamic>? data = isEdit ? doc.data() as Map<String, dynamic> : null;

    final timeController = TextEditingController(text: isEdit ? data!['time'] : '07:30 - 09:00');
    final dateController = TextEditingController(text: isEdit ? (data!['date'] ?? '') : DateTime.now().toString().substring(0, 10));
    
    String? selectedClass = isEdit ? data!['className'] : null;
    String? selectedTeacher = isEdit ? data!['teacherName'] : null;
    String? selectedRoom = isEdit ? data!['room'] : null;
    String selectedDay = isEdit ? data!['day'] : daysOfWeek[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Cập Nhật Lịch Học' : 'Thêm Lịch Học'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('students').snapshots(),
                builder: (context, snapshot) {
                  List<String> classes = [];
                  if (snapshot.hasData) {
                    classes = snapshot.data!.docs.map((d) => (d.data() as Map)['className'].toString()).toSet().toList()..sort();
                  }
                  return DropdownButtonFormField<String>(
                    value: selectedClass,
                    items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setDialogState(() => selectedClass = v),
                    decoration: const InputDecoration(labelText: 'Lớp học'),
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('teachers').snapshots(),
                builder: (context, snapshot) {
                  List<String> teachers = [];
                  if (snapshot.hasData) {
                    teachers = snapshot.data!.docs.map((d) => (d.data() as Map)['name'].toString()).toList()..sort();
                  }
                  return DropdownButtonFormField<String>(
                    value: selectedTeacher,
                    items: teachers.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setDialogState(() => selectedTeacher = v),
                    decoration: const InputDecoration(labelText: 'Giáo viên'),
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
                builder: (context, snapshot) {
                  List<String> rooms = [];
                  if (snapshot.hasData) {
                    rooms = snapshot.data!.docs.map((d) => (d.data() as Map)['name'].toString()).toList()..sort();
                  }
                  return DropdownButtonFormField<String>(
                    value: selectedRoom,
                    items: rooms.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => setDialogState(() => selectedRoom = v),
                    decoration: const InputDecoration(labelText: 'Chọn phòng học'),
                  );
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedDay,
                items: daysOfWeek.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setDialogState(() => selectedDay = v!),
                decoration: const InputDecoration(labelText: 'Thứ'),
              ),
              TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Ngày (YYYY-MM-DD)')),
              TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Thời gian (VD: 07:30 - 09:00)')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(onPressed: () async {
              if (selectedClass == null || selectedTeacher == null || selectedRoom == null) return;
              
              // --- KIỂM TRA TRÙNG LỊCH ---
              bool hasConflict = await _checkRoomConflict(
                room: selectedRoom!,
                day: selectedDay,
                date: dateController.text,
                newTime: timeController.text,
                excludeDocId: doc?.id,
              );

              if (hasConflict) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('CẢNH BÁO: Phòng $selectedRoom đã có lịch trong khung giờ này!'), backgroundColor: Colors.red),
                  );
                }
                return;
              }

              Map<String, dynamic> timetableData = {
                'day': selectedDay,
                'date': dateController.text,
                'subject': 'Lớp $selectedClass', // Môn học mặc định lấy theo tên lớp
                'time': timeController.text,
                'className': selectedClass,
                'teacherName': selectedTeacher,
                'room': selectedRoom,
              };

              if (isEdit) {
                await doc.reference.update(timetableData);
              } else {
                timetableData['attendedStudents'] = [];
                timetableData['attendanceCode'] = null;
                await FirebaseFirestore.instance.collection('timetable').add(timetableData);
              }
              
              if (mounted) Navigator.pop(context);
            }, child: const Text('Lưu'))
          ],
        ),
      ),
    );
  }

  Future<bool> _checkRoomConflict({required String room, required String day, required String date, required String newTime, String? excludeDocId}) async {
    final query = await FirebaseFirestore.instance.collection('timetable')
        .where('room', isEqualTo: room)
        .where('day', isEqualTo: day)
        .get();

    for (var d in query.docs) {
      if (d.id == excludeDocId) continue;
      if (d['date'] != date && date.isNotEmpty && d['date'].toString().isNotEmpty) continue;
      
      if (_isTimeOverlap(newTime, d['time'])) return true;
    }
    return false;
  }

  bool _isTimeOverlap(String time1, String time2) {
    try {
      List<int> parse(String t) {
        var parts = t.split('-');
        int start = _toMin(parts[0].trim());
        int end = _toMin(parts[1].trim());
        return [start, end];
      }
      var t1 = parse(time1);
      var t2 = parse(time2);
      return t1[0] < t2[1] && t2[0] < t1[1];
    } catch (e) { return false; }
  }

  int _toMin(String s) {
    var p = s.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  void _showAddRoomDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Phòng Học'),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên phòng (VD: A101)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(onPressed: () async {
            if (nameController.text.isEmpty) return;
            await FirebaseFirestore.instance.collection('rooms').add({'name': nameController.text});
            if (mounted) Navigator.pop(context);
          }, child: const Text('Thêm'))
        ],
      ),
    );
  }

  Widget _buildRoomTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rooms').orderBy('name').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final doc = snapshot.data!.docs[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.meeting_room, color: Colors.blueAccent),
                title: Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => doc.reference.delete()),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]))),
        title: const Text('Quản Trị Nhà Trường', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildStudentTab(),
          _buildTeacherTab(),
          _buildTimetableTab(),
          _buildRoomTab(),
          const EventsAdminTab(),
          _buildNewsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Học sinh'),
          BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'Giáo viên'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch học'),
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: 'Phòng'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Sự kiện'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Bảng tin'),
        ],
      ),
      floatingActionButton: (_currentIndex != 4) ? FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          if (_currentIndex == 0) _showAddStudentDialog();
          else if (_currentIndex == 1) _showAddTeacherDialog();
          else if (_currentIndex == 2) _showAddTimetableDialog();
          else if (_currentIndex == 3) _showAddRoomDialog();
          else if (_currentIndex == 5) _showAddNewsDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildStudentTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('students').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        final classes = docs.map((d) => (d.data() as Map)['className'].toString()).toSet().toList()..sort();
        return ListView.builder(
          itemCount: classes.length,
          itemBuilder: (context, i) {
            final cls = classes[i];
            final sts = docs.where((d) => (d.data() as Map)['className'] == cls).toList();
            return ExpansionTile(
              title: Text('Lớp $cls', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent), overflow: TextOverflow.ellipsis),
              children: sts.map((s) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text((s.data() as Map)['name'], overflow: TextOverflow.ellipsis),
                subtitle: Text('ID: ${s.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showAddStudentDialog(doc: s)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => s.reference.delete()),
                  ],
                ),
              )).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildTeacherTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('teachers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final t = snapshot.data!.docs[i];
            final data = t.data() as Map;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                subtitle: Text('SĐT: ${data['phone']} | ID: ${data['id']}', overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showAddTeacherDialog(doc: t)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => t.reference.delete()),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimetableTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('timetable').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        final classes = docs.map((d) => (d.data() as Map)['className'].toString()).toSet().toList()..sort();
        
        return ListView.builder(
          itemCount: classes.length,
          itemBuilder: (context, i) {
            final cls = classes[i];
            final classDocs = docs.where((d) => (d.data() as Map)['className'] == cls).toList();
            
            return ExpansionTile(
              title: Text('Lớp $cls', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent), overflow: TextOverflow.ellipsis),
              children: daysOfWeek.map((day) {
                final dayDocs = classDocs.where((d) => (d.data() as Map)['day'] == day).toList();
                if (dayDocs.isEmpty) return const SizedBox.shrink();
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_view_day, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                    ...dayDocs.map((it) {
                      final d = it.data() as Map;
                      final subject = d['subject'].toString().toLowerCase();
                      Color cardColor = Colors.blueAccent;
                      IconData subjectIcon = Icons.book;

                      if (subject.contains('toán')) { cardColor = Colors.redAccent; subjectIcon = Icons.calculate; }
                      else if (subject.contains('văn')) { cardColor = Colors.orange; subjectIcon = Icons.history_edu; }
                      else if (subject.contains('anh')) { cardColor = Colors.purple; subjectIcon = Icons.language; }
                      else if (subject.contains('lý') || subject.contains('hóa')) { cardColor = Colors.teal; subjectIcon = Icons.science; }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: cardColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Icon(subjectIcon, color: cardColor),
                          ),
                          title: Text(d['subject'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('GV: ${d['teacherName']} | Phòng: ${d['room'] ?? 'N/A'}\n${d['time']} (${d['date'] ?? ''})', style: const TextStyle(fontSize: 12)),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                                onPressed: () => _showAddTimetableDialog(doc: it),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                onPressed: () => it.reference.delete(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildNewsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('notifications').orderBy('date', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map;
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${data['date']}\n${data['content'] ?? ''}'),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => docs[i].reference.delete()),
              ),
            );
          },
        );
      },
    );
  }
}
