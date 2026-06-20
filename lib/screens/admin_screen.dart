// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;
  final List<String> daysOfWeek = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
  final List<String> gradeTypes = ['Miệng / 15 Phút', '1 Tiết / Giữa Kỳ', 'Học Kỳ'];

  String _getWeekdayString(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      List<String> weekdays = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
      return weekdays[dt.weekday - 1];
    } catch (_) {
      return 'Thứ 2';
    }
  }

  // ================= 1. QUẢN LÝ BẢNG TIN =================
  void _showAddNewsDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();
    String selectedCategory = 'Chung';
    final List<String> categories = ['Chung', 'Học phí', 'Lịch thi', 'Sự kiện'];

    DateTime chosenDate = DateTime.now();
    TextEditingController dateController = TextEditingController(text: "${chosenDate.day.toString().padLeft(2, '0')}/${chosenDate.month.toString().padLeft(2, '0')}/${chosenDate.year}");

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Viết Bản tin mới', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Chuyên mục', border: OutlineInputBorder()),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setDialogState(() => selectedCategory = val!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateController, readOnly: true,
                  decoration: const InputDecoration(labelText: 'Ngày đăng', suffixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder()),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(context: context, initialDate: chosenDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                    if (picked != null) { chosenDate = picked; setDialogState(() { dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}"; }); }
                  },
                ),
                const SizedBox(height: 10),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tiêu đề', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: contentController, maxLines: 4, decoration: const InputDecoration(labelText: 'Nội dung chi tiết', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('notifications').add({
                    'title': titleController.text,
                    'content': contentController.text,
                    'date': dateController.text,
                    'category': selectedCategory,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng bản tin thành công!'), backgroundColor: Colors.green));
                  }
                },
                child: const Text('Đăng bài', style: TextStyle(color: Colors.white))
            )
          ],
        ),
      ),
    );
  }

  void _showEditNewsDialog(DocumentSnapshot doc) {
    Map<String, dynamic> post = doc.data() as Map<String, dynamic>;
    TextEditingController titleController = TextEditingController(text: post['title']);
    TextEditingController contentController = TextEditingController(text: post['content']);
    TextEditingController dateController = TextEditingController(text: post['date']);
    String selectedCategory = post['category'] ?? 'Chung';
    final List<String> categories = ['Chung', 'Học phí', 'Lịch thi', 'Sự kiện'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Sửa Bản tin', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(value: selectedCategory, decoration: const InputDecoration(labelText: 'Chuyên mục', border: OutlineInputBorder()), items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) => setDialogState(() => selectedCategory = val!)),
                const SizedBox(height: 10),
                TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Ngày đăng', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tiêu đề', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: contentController, maxLines: 4, decoration: const InputDecoration(labelText: 'Nội dung chi tiết', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () async {
                  await doc.reference.update({
                    'title': titleController.text,
                    'content': contentController.text,
                    'date': dateController.text,
                    'category': selectedCategory,
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green));
                  }
                },
                child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white))
            )
          ],
        ),
      ),
    );
  }

  // ================= 2. QUẢN LÝ GIÁO VIÊN =================
  void _showAddTeacherDialog() {
    TextEditingController idController = TextEditingController(); 
    TextEditingController nameController = TextEditingController(); 
    TextEditingController phoneController = TextEditingController(); 
    TextEditingController passwordController = TextEditingController();
    
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('Thêm Giáo Viên Mới', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)), 
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã GV (VD: GV004)', border: OutlineInputBorder())), 
              const SizedBox(height: 10),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và Tên', border: OutlineInputBorder())), 
              const SizedBox(height: 10),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder())), 
              const SizedBox(height: 10),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder()))
            ]
          ),
        ), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), 
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
              if (idController.text.isEmpty || nameController.text.isEmpty) return;
              try {
                await FirebaseFirestore.instance.collection('teachers').doc(idController.text).set({
                  'id': idController.text,
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'password': passwordController.text,
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã lưu giáo viên lên hệ thống!'), backgroundColor: Colors.green)
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red)
                  );
                }
              }
            }, 
            child: const Text('Lưu vào Database', style: TextStyle(color: Colors.white))
          )
        ]
      )
    );
  }
  void _showEditTeacherDialog(DocumentSnapshot doc) {
    Map<String, dynamic> teacher = doc.data() as Map<String, dynamic>;
    TextEditingController idController = TextEditingController(text: teacher['id']); TextEditingController nameController = TextEditingController(text: teacher['name']); TextEditingController phoneController = TextEditingController(text: teacher['phone']); TextEditingController passwordController = TextEditingController(text: teacher['password']);
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Sửa Thông Tin Giáo Viên', style: TextStyle(color: Colors.blue)), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã GV'), readOnly: true), TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và Tên')), TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại')), TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), ElevatedButton(onPressed: () async {
      await doc.reference.update({
        'name': nameController.text,
        'phone': phoneController.text,
        'password': passwordController.text,
      });
      if (context.mounted) Navigator.pop(context);
    }, child: const Text('Cập nhật'))]));
  }

  // ================= 3. QUẢN LÝ HỌC SINH & ĐIỂM SỐ =================
  void _showAddStudentDialog() {
    TextEditingController idController = TextEditingController(); 
    TextEditingController nameController = TextEditingController(); 
    TextEditingController classController = TextEditingController(); 
    TextEditingController passwordController = TextEditingController();
    
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text('Thêm Học Sinh Mới', style: TextStyle(fontWeight: FontWeight.bold)), 
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã HS', border: OutlineInputBorder())), 
              const SizedBox(height: 10),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và Tên', border: OutlineInputBorder())), 
              const SizedBox(height: 10),
              TextField(controller: classController, decoration: const InputDecoration(labelText: 'Lớp', border: OutlineInputBorder())), 
              const SizedBox(height: 10),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu', border: OutlineInputBorder()))
            ]
          ),
        ), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), 
          ElevatedButton(
            onPressed: () async {
              if (idController.text.isEmpty) return;
              try {
                await FirebaseFirestore.instance.collection('students').doc(idController.text).set({
                  'id': idController.text,
                  'name': nameController.text,
                  'className': classController.text,
                  'password': passwordController.text,
                  'grades': {},
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã lưu học sinh thành công!'), backgroundColor: Colors.green)
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red)
                  );
                }
              }
            }, 
            child: const Text('Lưu')
          )
        ]
      )
    );
  }
  void _showEditStudentDialog(DocumentSnapshot doc) {
    Map<String, dynamic> student = doc.data() as Map<String, dynamic>;
    TextEditingController idController = TextEditingController(text: student['id']); TextEditingController nameController = TextEditingController(text: student['name']); TextEditingController classController = TextEditingController(text: student['className']); TextEditingController passwordController = TextEditingController(text: student['password']);
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Sửa Thông Tin'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã HS'), readOnly: true), TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và Tên')), TextField(controller: classController, decoration: const InputDecoration(labelText: 'Lớp')), TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), ElevatedButton(onPressed: () async {
      await doc.reference.update({
        'name': nameController.text,
        'className': classController.text,
        'password': passwordController.text,
      });
      if (context.mounted) Navigator.pop(context);
    }, child: const Text('Cập nhật'))]));
  }

  void _showGradesBottomSheet(BuildContext context, DocumentSnapshot studentDoc) {
    Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;
    Map<String, dynamic> grades = Map<String, dynamic>.from(studentData['grades'] ?? {});

    // Lấy danh sách môn học từ TKB của lớp này
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (BuildContext context) {
      return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('timetable').where('className', isEqualTo: studentData['className']).get(),
        builder: (context, snapshot) {
          List<String> subjects = snapshot.data?.docs.map((d) => d['subject'] as String).toSet().toList() ?? ['Toán Học', 'Ngữ Văn', 'Tiếng Anh'];
          if (subjects.isEmpty) subjects = ['Toán Học', 'Ngữ Văn', 'Tiếng Anh'];
          
          String selectedSubject = subjects.first; String selectedType = gradeTypes.first; TextEditingController scoreController = TextEditingController();

          return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
            return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: FractionallySizedBox(heightFactor: 0.8, child: Column(children: [Padding(padding: const EdgeInsets.all(16.0), child: Text('Chấm điểm: ${studentData['name']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue))), Container(padding: const EdgeInsets.all(16.0), color: Colors.blue.shade50, child: Column(children: [Row(children: [Expanded(child: DropdownButtonFormField<String>(value: selectedSubject, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Môn'), items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (val) => setModalState(() => selectedSubject = val!))), const SizedBox(width: 10), Expanded(child: DropdownButtonFormField<String>(value: selectedType, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Loại'), items: gradeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(), onChanged: (val) => setModalState(() => selectedType = val!)))]), const SizedBox(height: 10), Row(children: [Expanded(child: TextField(controller: scoreController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Điểm số'))), const SizedBox(width: 10), ElevatedButton(onPressed: () async {
              double? sc = double.tryParse(scoreController.text);
              if (sc != null && sc >= 0 && sc <= 10) {
                if (grades[selectedSubject] == null) {
                  grades[selectedSubject] = {'Miệng / 15 Phút': [], '1 Tiết / Giữa Kỳ': [], 'Học Kỳ': []};
                }
                List<dynamic> currentGrades = List.from(grades[selectedSubject][selectedType] ?? []);
                currentGrades.add(sc);
                grades[selectedSubject][selectedType] = currentGrades;

                await studentDoc.reference.update({'grades': grades});
                setModalState(() {
                  scoreController.clear();
                });
              }
            }, child: const Text('Lưu'))])])), Expanded(child: grades.isEmpty ? const Center(child: Text('Chưa có điểm')) : ListView(children: grades.entries.map((e) => ExpansionTile(title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)), children: (e.value as Map).entries.map((te) => ListTile(title: Text(te.key), trailing: Text((te.value as List).isEmpty ? '-' : (te.value as List).join(" | ")))).toList())).toList()))])));
          });
        }
      );
    });
  }

  // ================= 4. QUẢN LÝ THỜI KHÓA BIỂU =================
  void _showAddTimetableDialog() async {
    final studentSnapshot = await FirebaseFirestore.instance.collection('students').get();
    final teacherSnapshot = await FirebaseFirestore.instance.collection('teachers').get();

    final List<String> classes = studentSnapshot.docs.map((doc) => doc['className'] as String).toSet().toList()..sort();
    final List<String> teacherNames = teacherSnapshot.docs.map((doc) => doc['name'] as String).toList();

    if (classes.isEmpty || teacherNames.isEmpty) return;

    String selectedClass = classes.first;
    String selectedTeacher = teacherNames.first;
    TextEditingController subjectController = TextEditingController();
    TextEditingController timeController = TextEditingController();
    DateTime chosenDate = DateTime.now();
    TextEditingController dateController = TextEditingController(text: "${chosenDate.year}-${chosenDate.month.toString().padLeft(2, '0')}-${chosenDate.day.toString().padLeft(2, '0')}");

    if (!mounted) return;

    showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(title: const Text('Thêm Lịch Học Mới', style: TextStyle(color: Colors.blue)), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButtonFormField<String>(value: selectedClass, decoration: const InputDecoration(labelText: 'Chọn Lớp'), items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) => setDialogState(() => selectedClass = val!)), DropdownButtonFormField<String>(value: selectedTeacher, decoration: const InputDecoration(labelText: 'Phân công Giáo viên'), items: teacherNames.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (val) => setDialogState(() => selectedTeacher = val!)), TextField(controller: dateController, readOnly: true, decoration: const InputDecoration(labelText: 'Ngày học', suffixIcon: Icon(Icons.calendar_today, color: Colors.blue)), onTap: () async { DateTime? picked = await showDatePicker(context: context, initialDate: chosenDate, firstDate: DateTime(2025), lastDate: DateTime(2030)); if (picked != null) { chosenDate = picked; setDialogState(() { dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}"; }); } }), TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Môn học')), TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Thời gian (VD: 07:00 - 08:30)'))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), ElevatedButton(onPressed: () async {
      await FirebaseFirestore.instance.collection('timetable').add({
        'date': dateController.text,
        'subject': subjectController.text,
        'time': timeController.text,
        'className': selectedClass,
        'teacherName': selectedTeacher,
      });
      if (context.mounted) Navigator.pop(context);
    }, child: const Text('Lưu'))])));
  }

  void _showEditTimetableDialog(DocumentSnapshot doc) async {
    Map<String, dynamic> lesson = doc.data() as Map<String, dynamic>;
    final studentSnapshot = await FirebaseFirestore.instance.collection('students').get();
    final teacherSnapshot = await FirebaseFirestore.instance.collection('teachers').get();

    final List<String> classes = studentSnapshot.docs.map((d) => d['className'] as String).toSet().toList()..sort();
    final List<String> teacherNames = teacherSnapshot.docs.map((d) => d['name'] as String).toList();

    String selectedClass = classes.contains(lesson['className']) ? lesson['className'] : (classes.isNotEmpty ? classes.first : '');
    String selectedTeacher = teacherNames.contains(lesson['teacherName']) ? lesson['teacherName'] : (teacherNames.isNotEmpty ? teacherNames.first : '');
    TextEditingController subjectController = TextEditingController(text: lesson['subject']);
    TextEditingController timeController = TextEditingController(text: lesson['time']);
    TextEditingController dateController = TextEditingController(text: lesson['date']);
    DateTime chosenDate = DateTime.parse(lesson['date']);

    if (!mounted) return;

    showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(title: const Text('Chỉnh sửa Lịch Học'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButtonFormField<String>(value: selectedClass, decoration: const InputDecoration(labelText: 'Chọn Lớp'), items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) => setDialogState(() => selectedClass = val!)), DropdownButtonFormField<String>(value: selectedTeacher, decoration: const InputDecoration(labelText: 'Phân công Giáo viên'), items: teacherNames.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (val) => setDialogState(() => selectedTeacher = val!)), TextField(controller: dateController, readOnly: true, decoration: const InputDecoration(labelText: 'Ngày học', suffixIcon: Icon(Icons.calendar_today)), onTap: () async { DateTime? picked = await showDatePicker(context: context, initialDate: chosenDate, firstDate: DateTime(2025), lastDate: DateTime(2030)); if (picked != null) { chosenDate = picked; setDialogState(() { dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}"; }); } }), TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Môn học')), TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Thời gian'))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), ElevatedButton(onPressed: () async {
      await doc.reference.update({
        'date': dateController.text,
        'subject': subjectController.text,
        'time': timeController.text,
        'className': selectedClass,
        'teacherName': selectedTeacher,
      });
      if (context.mounted) Navigator.pop(context);
    }, child: const Text('Cập nhật'))])));
  }

  void _showAttendanceBottomSheet(BuildContext context, DocumentSnapshot lessonDoc) {
    Map<String, dynamic> lesson = lessonDoc.data() as Map<String, dynamic>;
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (BuildContext context) {
      return StreamBuilder<DocumentSnapshot>(
        stream: lessonDoc.reference.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          Map<String, dynamic> currentLessonData = snapshot.data!.data() as Map<String, dynamic>;
          String? currentCode = currentLessonData['attendanceCode'];
          List<dynamic> attendedList = currentLessonData['attendedStudents'] ?? [];

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('students').where('className', isEqualTo: lesson['className']).get(),
            builder: (context, studentSnapshot) {
              List<DocumentSnapshot> studentsInClass = studentSnapshot.data?.docs ?? [];

              return FractionallySizedBox(heightFactor: 0.8, child: Column(children: [Padding(padding: const EdgeInsets.all(16.0), child: Text('Điểm danh: ${lesson['subject']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), Container(width: double.infinity, padding: const EdgeInsets.all(16.0), color: Colors.blue.shade50, child: Column(children: [if (currentCode != null) Text(currentCode, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 5)) else const Text('Chưa mở điểm danh', style: TextStyle(color: Colors.red)), ElevatedButton(onPressed: () async {
                String newCode = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
                await lessonDoc.reference.update({
                  'attendanceCode': newCode,
                  'attendedStudents': currentLessonData['attendedStudents'] ?? [],
                });
              }, child: const Text('Tạo mã'))])), Expanded(child: ListView.builder(itemCount: studentsInClass.length, itemBuilder: (context, index) {
                final studentDoc = studentsInClass[index];
                final student = studentDoc.data() as Map<String, dynamic>;
                final isAttended = attendedList.contains(student['id']);
                return CheckboxListTile(value: isAttended, title: Text(student['name'] ?? ''), secondary: Icon(isAttended ? Icons.check_circle : Icons.radio_button_unchecked, color: isAttended ? Colors.green : Colors.grey), onChanged: (val) async {
                  List<dynamic> newList = List.from(attendedList);
                  if (val == true) { newList.add(student['id']); } else { newList.remove(student['id']); }
                  await lessonDoc.reference.update({'attendedStudents': newList});
                });
              }))]));
            }
          );
        }
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // TAB 1: DANH SÁCH LỚP HỌC
    Widget studentListTab = Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Lỗi kết nối: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final studentDocs = snapshot.data?.docs ?? [];
          final classes = studentDocs.map((doc) => doc['className'] as String).toSet().toList()..sort();

          if (classes.isEmpty) return const Center(child: Text('Chưa có học sinh'));

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, classIndex) {
              String currentClass = classes[classIndex];
              List<DocumentSnapshot> studentsInClass = studentDocs.where((doc) => doc['className'] == currentClass).toList();
              return ExpansionTile(
                initiallyExpanded: true, title: Text('Lớp: $currentClass', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                children: studentsInClass.map((doc) {
                  final student = doc.data() as Map<String, dynamic>;
                  return Card(margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ListTile(leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white)), title: Text(student['name'] ?? ''), subtitle: Text('Mã: ${student['id']} | MK: ${student['password']}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.star, color: Colors.amber), onPressed: () => _showGradesBottomSheet(context, doc)), IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditStudentDialog(doc)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete())])));
                }).toList(),
              );
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddStudentDialog, backgroundColor: Colors.blueAccent, child: const Icon(Icons.add, color: Colors.white)),
    );

    // TAB 2: QUẢN LÝ GIÁO VIÊN
    Widget teacherListTab = Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('teachers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Lỗi kết nối: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final teacherDocs = snapshot.data?.docs ?? [];

          if (teacherDocs.isEmpty) return const Center(child: Text('Chưa có giáo viên'));

          return ListView.builder(
            itemCount: teacherDocs.length,
            itemBuilder: (context, index) {
              final doc = teacherDocs[index];
              final teacher = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.work, color: Colors.white)),
                  title: Text(teacher['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Mã GV: ${teacher['id']} | SĐT: ${teacher['phone']}\nMK: ${teacher['password']}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditTeacherDialog(doc)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete())]),
                ),
              );
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddTeacherDialog, backgroundColor: Colors.indigo, child: const Icon(Icons.add, color: Colors.white)),
    );

    // TAB 3: THỜI KHÓA BIỂU
    Widget timetableTab = DefaultTabController(
      length: daysOfWeek.length,
      child: Scaffold(
        appBar: PreferredSize(preferredSize: const Size.fromHeight(50.0), child: AppBar(backgroundColor: Colors.white, bottom: TabBar(isScrollable: true, tabs: daysOfWeek.map((day) => Tab(text: day)).toList()))),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('timetable').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final timetableDocs = snapshot.data?.docs ?? [];

            return TabBarView(
              children: daysOfWeek.map((day) {
                final lessonsOfDay = timetableDocs.where((doc) => _getWeekdayString(doc['date']) == day).toList()..sort((a, b) => (a['time'] as String).compareTo(b['time']));
                if (lessonsOfDay.isEmpty) return Center(child: Text('Không có lịch học $day'));
                return ListView.builder(
                  itemCount: lessonsOfDay.length,
                  itemBuilder: (context, index) {
                    final doc = lessonsOfDay[index];
                    final lesson = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.green.shade100, child: const Icon(Icons.menu_book, color: Colors.green)),
                        title: Text(lesson['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${lesson['time']} | Ngày: ${lesson['date']}\nLớp: ${lesson['className']} | GV: ${lesson['teacherName']}'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.green), onPressed: () => _showAttendanceBottomSheet(context, doc)), IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditTimetableDialog(doc)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete())]),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          }
        ),
        floatingActionButton: FloatingActionButton(onPressed: _showAddTimetableDialog, backgroundColor: Colors.green, child: const Icon(Icons.add, color: Colors.white)),
      ),
    );

    // TAB 4: QUẢN LÝ BẢNG TIN THÔNG BÁO
    Widget newsTab = Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final newsDocs = snapshot.data?.docs ?? [];

          if (newsDocs.isEmpty) return const Center(child: Text('Chưa có thông báo nào'));

          return ListView.builder(
            itemCount: newsDocs.length,
            itemBuilder: (context, index) {
              final doc = newsDocs[index];
              final post = doc.data() as Map<String, dynamic>;
              Color catColor = Colors.blue;
              if (post['category'] == 'Học phí') catColor = Colors.red;
              if (post['category'] == 'Lịch thi') catColor = Colors.orange;
              if (post['category'] == 'Sự kiện') catColor = Colors.purple;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: CircleAvatar(backgroundColor: catColor.withOpacity(0.2), child: Icon(Icons.newspaper, color: catColor)),
                  title: Text(post['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${post['category']} • ${post['date']}\n${post['content']}', maxLines: 2, overflow: TextOverflow.ellipsis),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditNewsDialog(doc)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => doc.reference.delete()),
                    ],
                  ),
                ),
              );
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddNewsDialog, backgroundColor: Colors.purple,
          icon: const Icon(Icons.add, color: Colors.white), label: const Text('Viết tin', style: TextStyle(color: Colors.white))
      ),
    );

    // GỘP 4 TAB CHO ADMIN
    final tabs = [studentListTab, teacherListTab, timetableTab, newsTab];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent], begin: Alignment.topLeft, end: Alignment.bottomRight))),
        title: const Text('Quản Trị Nhà Trường', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Học sinh'),
            BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'Giáo viên'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch học'),
            BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Bảng tin'),
          ]
      ),
    );
  }
}
