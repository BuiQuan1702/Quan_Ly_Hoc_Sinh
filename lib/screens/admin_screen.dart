// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // Thêm import này
import 'events_admin_tab.dart'; 

// Thêm class Formatter này ở ngoài class AdminScreen
class TimeMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 8) text = text.substring(0, 8);
    
    var newText = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2) newText += ':';
      if (i == 4) newText += ' - ';
      if (i == 6) newText += ':';
      newText += text[i];
    }
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;
  final List<String> daysOfWeek = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];

  // ================= QUẢN LÝ THÔNG BÁO =================
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

  // ================= QUẢN LÝ GIÁO VIÊN =================
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

  // ================= QUẢN LÝ HỌC SINH (MỚI: Dùng Dropdown từ danh sách lớp) =================
  void _showAddStudentDialog({DocumentSnapshot? doc}) {
    bool isEdit = doc != null;
    Map<String, dynamic>? data = isEdit ? doc.data() as Map<String, dynamic> : null;

    final idController = TextEditingController(text: isEdit ? data!['id'] : '');
    final nameController = TextEditingController(text: isEdit ? data!['name'] : '');
    final passwordController = TextEditingController(text: isEdit ? data!['password'] : '');
    String? selectedClass;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Cập nhật Học Sinh' : 'Thêm Học Sinh'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã HS (ID)'), readOnly: isEdit),
              const SizedBox(height: 10),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ Tên')),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('classes').orderBy('name').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  var classes = snapshot.data!.docs.map((d) => d['name'].toString()).toList();
                  if (classes.isEmpty) return const Text('Hãy tạo lớp học trước!');
                  
                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedClass,
                    decoration: const InputDecoration(labelText: 'Chọn lớp học', border: OutlineInputBorder()),
                    items: classes.map((c) => DropdownMenuItem(
                      value: c, 
                      child: Text(c, overflow: TextOverflow.ellipsis)
                    )).toList(),
                    onChanged: (v) => setDialogState(() => selectedClass = v),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu')),
              if (isEdit) Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('Lớp hiện tại: ${(data!['classNames'] as List? ?? []).join(", ")}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(onPressed: () async {
              if (idController.text.isEmpty || selectedClass == null) return;
              
              final studentRef = FirebaseFirestore.instance.collection('students').doc(idController.text);
              final studentDoc = await studentRef.get();

              if (studentDoc.exists) {
                // Nếu trùng ID -> Cập nhật tên/mật khẩu và THÊM lớp mới vào danh sách
                await studentRef.update({
                  'name': nameController.text,
                  'password': passwordController.text,
                  'classNames': FieldValue.arrayUnion([selectedClass])
                });
              } else {
                // Nếu HS mới -> Tạo mới với lớp đã chọn
                await studentRef.set({
                  'id': idController.text,
                  'name': nameController.text,
                  'password': passwordController.text,
                  'classNames': [selectedClass],
                  'grades': {},
                });
              }
              if (mounted) Navigator.pop(context);
            }, child: const Text('Lưu'))
          ],
        ),
      ),
    );
  }

  // ================= QUẢN LÝ LỊCH HỌC =================
  Future<bool> _checkRoomConflict({required String room, required String day, required String date, required String newTime, String? excludeDocId}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('timetable')
        .where('room', isEqualTo: room)
        .where('day', isEqualTo: day)
        .where('date', isEqualTo: date)
        .get();

    for (var doc in snapshot.docs) {
      if (doc.id == excludeDocId) continue;
      String existingTime = doc['time'];
      if (_isTimeOverlapping(existingTime, newTime)) return true;
    }
    return false;
  }

  bool _isTimeOverlapping(String time1, String time2) {
    try {
      List<String> parts1 = time1.split(' - ');
      List<String> parts2 = time2.split(' - ');

      int start1 = _timeToMinutes(parts1[0]);
      int end1 = _timeToMinutes(parts1[1]);
      int start2 = _timeToMinutes(parts2[0]);
      int end2 = _timeToMinutes(parts2[1]);

      return (start1 < end2 && start2 < end1);
    } catch (e) {
      return false;
    }
  }

  int _timeToMinutes(String time) {
    List<String> hm = time.split(':');
    return int.parse(hm[0]) * 60 + int.parse(hm[1]);
  }

  void _showAddTimetableDialog({DocumentSnapshot? doc}) {
    bool isEdit = doc != null;
    Map<String, dynamic>? data = isEdit ? doc.data() as Map<String, dynamic> : null;

    final timeController = TextEditingController(text: isEdit ? data!['time'] : '07:30 - 09:00');
    final dateController = TextEditingController(text: isEdit ? (data!['date'] ?? '') : DateTime.now().toString().substring(0, 10));
    
    String? selectedClass = isEdit ? data!['className'] : null;
    String? selectedTeacher = isEdit ? data!['teacherName'] : null;
    String? selectedRoom = isEdit ? data!['room'] : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEdit ? 'Cập Nhật Lịch Học' : 'Thêm Lịch Học', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('classes').orderBy('name').snapshots(),
                builder: (context, snapshot) {
                  List<String> classes = [];
                  if (snapshot.hasData) {
                    classes = snapshot.data!.docs.map((d) => d['name'].toString()).toList();
                  }
                  return DropdownButtonFormField<String>(
                    value: selectedClass,
                    items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setDialogState(() => selectedClass = v),
                    decoration: const InputDecoration(labelText: 'Lớp học', border: UnderlineInputBorder()),
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('teachers').orderBy('name').snapshots(),
                builder: (context, snapshot) {
                  List<String> teachers = [];
                  if (snapshot.hasData) {
                    teachers = snapshot.data!.docs.map((d) => d['name'].toString()).toList();
                  }
                  return DropdownButtonFormField<String>(
                    value: selectedTeacher,
                    items: teachers.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setDialogState(() => selectedTeacher = v),
                    decoration: const InputDecoration(labelText: 'Giáo viên', border: UnderlineInputBorder()),
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('rooms').orderBy('name').snapshots(),
                builder: (context, snapshot) {
                  List<String> rooms = [];
                  if (snapshot.hasData) {
                    rooms = snapshot.data!.docs.map((d) => d['name'].toString()).toList();
                  }
                  return DropdownButtonFormField<String>(
                    value: selectedRoom,
                    items: rooms.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => setDialogState(() => selectedRoom = v),
                    decoration: const InputDecoration(labelText: 'Chọn phòng học', border: UnderlineInputBorder()),
                  );
                },
              ),
              const SizedBox(height: 10),
              // CHỌN NGÀY QUA LỊCH (Tự động tính Thứ)
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Ngày học', suffixIcon: Icon(Icons.calendar_month, color: Colors.blueAccent), border: UnderlineInputBorder()),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setDialogState(() => dateController.text = picked.toString().substring(0, 10));
                  }
                },
              ),
              const SizedBox(height: 10),
              // NHẬP THỜI GIAN THỦ CÔNG (ĐỊNH DẠNG TỰ ĐỘNG)
              TextField(
                controller: timeController,
                keyboardType: TextInputType.number,
                inputFormatters: [TimeMaskFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Thời gian (Nhập số: 07000830)',
                  hintText: 'HH:mm - HH:mm',
                  suffixIcon: Icon(Icons.access_time, color: Colors.blueAccent),
                  border: UnderlineInputBorder(),
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                if (selectedClass == null || selectedTeacher == null || selectedRoom == null || dateController.text.isEmpty) return;
                
                // TỰ ĐỘNG TÍNH THỨ TỪ NGÀY
                DateTime selectedDateTime = DateTime.parse(dateController.text);
                String calculatedDay = daysOfWeek[selectedDateTime.weekday - 1];

                bool hasConflict = await _checkRoomConflict(
                  room: selectedRoom!,
                  day: calculatedDay,
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
                  'day': calculatedDay,
                  'date': dateController.text,
                  'subject': 'Lớp $selectedClass', 
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
              },
              child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  // ================= QUẢN LÝ PHÒNG / LỚP HỌC =================
  void _showAddRoomDialog({DocumentSnapshot? doc}) {
    bool isEdit = doc != null;
    final nameController = TextEditingController(text: isEdit ? (doc.data() as Map)['name'] : '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Sửa Phòng Học' : 'Thêm Phòng Học'),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên phòng (VD: A101)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(onPressed: () async {
            if (nameController.text.isEmpty) return;
            if (isEdit) {
              await doc.reference.update({'name': nameController.text});
            } else {
              await FirebaseFirestore.instance.collection('rooms').add({'name': nameController.text});
            }
            if (mounted) Navigator.pop(context);
          }, child: Text(isEdit ? 'Lưu' : 'Thêm'))
        ],
      ),
    );
  }

  void _showAddClassDialog({DocumentSnapshot? doc}) {
    bool isEdit = doc != null;
    final nameController = TextEditingController(text: isEdit ? (doc.data() as Map)['name'] : '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Sửa Lớp Học' : 'Tạo Lớp Học Mới'),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên lớp (VD: 10A1)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(onPressed: () async {
            if (nameController.text.isEmpty) return;
            if (isEdit) {
              await doc.reference.update({'name': nameController.text});
            } else {
              await FirebaseFirestore.instance.collection('classes').add({'name': nameController.text});
            }
            if (mounted) Navigator.pop(context);
          }, child: Text(isEdit ? 'Lưu' : 'Tạo lớp'))
        ],
      ),
    );
  }

  // ================= TABS BUILDERS =================
  Widget _buildStudentTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('students').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        
        Set<String> allClassNames = {};
        for (var d in docs) {
          var data = d.data() as Map;
          var classes = data['classNames'] as List? ?? [];
          for (var c in classes) allClassNames.add(c.toString());
          if (data['className'] != null) allClassNames.add(data['className'].toString());
        }
        final sortedClasses = allClassNames.toList()..sort();

        return ListView.builder(
          itemCount: sortedClasses.length,
          itemBuilder: (context, i) {
            final cls = sortedClasses[i];
            final sts = docs.where((d) {
              var data = d.data() as Map;
              var classes = data['classNames'] as List? ?? [];
              return classes.contains(cls) || data['className'] == cls;
            }).toList();

            return ExpansionTile(
              title: Text('Lớp $cls', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              children: sts.map((s) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text((s.data() as Map)['name']),
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
                title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('SĐT: ${data['phone']} | ID: ${data['id']}'),
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
              title: Text('Lớp $cls', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              children: daysOfWeek.map((day) {
                final dayDocs = classDocs.where((d) => (d.data() as Map)['day'] == day).toList();
                if (dayDocs.isEmpty) return const SizedBox.shrink();
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    ...dayDocs.map((it) {
                      final d = it.data() as Map;
                      return ListTile(
                        title: Text(d['subject']),
                        subtitle: Text('GV: ${d['teacherName']} | P: ${d['room']}\n${d['time']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showAddTimetableDialog(doc: it)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => it.reference.delete()),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            );
          },
        );
      },
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
            return ListTile(
              title: Text(doc['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showAddRoomDialog(doc: doc)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => doc.reference.delete()),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildClassTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('classes').orderBy('name').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final doc = snapshot.data!.docs[i];
            return ListTile(
              title: Text(doc['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showAddClassDialog(doc: doc)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => doc.reference.delete()),
                ],
              ),
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
            return ListTile(title: Text(data['title'] ?? ''), subtitle: Text(data['date']), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => docs[i].reference.delete()));
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
        actions: [
          IconButton(icon: const Icon(Icons.event, color: Colors.white), tooltip: 'Sự kiện', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(appBar: AppBar(title: const Text('Sự kiện')), body: const EventsAdminTab())))),
          IconButton(icon: const Icon(Icons.campaign, color: Colors.white), tooltip: 'Bảng tin', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(appBar: AppBar(title: const Text('Bảng tin'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: _showAddNewsDialog)]), body: _buildNewsTab())))),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildStudentTab(),
          _buildTeacherTab(),
          _buildTimetableTab(),
          _buildRoomTab(),
          _buildClassTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Học sinh'),
          BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'Giáo viên'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch học'),
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: 'Phòng'),
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Lớp học'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          if (_currentIndex == 0) _showAddStudentDialog();
          else if (_currentIndex == 1) _showAddTeacherDialog();
          else if (_currentIndex == 2) _showAddTimetableDialog();
          else if (_currentIndex == 3) _showAddRoomDialog();
          else if (_currentIndex == 4) _showAddClassDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
