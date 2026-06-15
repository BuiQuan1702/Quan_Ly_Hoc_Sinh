// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import '../models/student.dart';
import 'events_admin_tab.dart';

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

  // ================= CÁC HÀM QUẢN LÝ GIÁO VIÊN (MỚI) =================
  void _showAddTeacherDialog() {
    TextEditingController idController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm Giáo Viên Mới', style: TextStyle(color: Colors.blue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã GV (VD: GV004)')),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và Tên')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(onPressed: () {
            setState(() { mockTeachers.add(Teacher(id: idController.text, name: nameController.text, phone: phoneController.text, password: passwordController.text)); });
            Navigator.pop(context);
          }, child: const Text('Lưu'))
        ],
      ),
    );
  }

  void _showEditTeacherDialog(int index) {
    Teacher teacher = mockTeachers[index];
    TextEditingController idController = TextEditingController(text: teacher.id);
    TextEditingController nameController = TextEditingController(text: teacher.name);
    TextEditingController phoneController = TextEditingController(text: teacher.phone);
    TextEditingController passwordController = TextEditingController(text: teacher.password);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa Thông Tin Giáo Viên', style: TextStyle(color: Colors.blue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã GV')),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và Tên')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(onPressed: () {
            setState(() {
              mockTeachers[index].id = idController.text; mockTeachers[index].name = nameController.text;
              mockTeachers[index].phone = phoneController.text; mockTeachers[index].password = passwordController.text;
            });
            Navigator.pop(context);
          }, child: const Text('Cập nhật'))
        ],
      ),
    );
  }

  void _deleteTeacher(int index) {
    setState(() { mockTeachers.removeAt(index); });
  }

  // ================= CÁC HÀM QUẢN LÝ HỌC SINH & ĐIỂM SỐ =================
  void _showAddStudentDialog() {
    TextEditingController idController = TextEditingController(); TextEditingController nameController = TextEditingController(); TextEditingController classController = TextEditingController(); TextEditingController passwordController = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Thêm Học Sinh Mới'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã HS')), TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và Tên')), TextField(controller: classController, decoration: const InputDecoration(labelText: 'Lớp')), TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), ElevatedButton(onPressed: () { setState(() { mockStudents.add(Student(id: idController.text, name: nameController.text, className: classController.text, password: passwordController.text)); }); Navigator.pop(context); }, child: const Text('Lưu'))]));
  }

  void _showEditStudentDialog(int index) {
    Student student = mockStudents[index]; TextEditingController idController = TextEditingController(text: student.id); TextEditingController nameController = TextEditingController(text: student.name); TextEditingController classController = TextEditingController(text: student.className); TextEditingController passwordController = TextEditingController(text: student.password);
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Sửa Thông Tin'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã HS')), TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và Tên')), TextField(controller: classController, decoration: const InputDecoration(labelText: 'Lớp')), TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), ElevatedButton(onPressed: () { setState(() { mockStudents[index].id = idController.text; mockStudents[index].name = nameController.text; mockStudents[index].className = classController.text; mockStudents[index].password = passwordController.text; }); Navigator.pop(context); }, child: const Text('Cập nhật'))]));
  }

  void _deleteStudent(int index) { setState(() { mockStudents.removeAt(index); }); }

  void _showGradesBottomSheet(BuildContext context, Student student) {
    List<String> subjects = mockTimetable.where((l) => l.className == student.className).map((l) => l.subject).toSet().toList();
    if (subjects.isEmpty) subjects = ['Toán Học', 'Ngữ Văn', 'Tiếng Anh', 'Vật Lý'];
    String selectedSubject = subjects.first; String selectedType = gradeTypes.first; TextEditingController scoreController = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (BuildContext context) { return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) { return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: FractionallySizedBox(heightFactor: 0.8, child: Column(children: [Padding(padding: const EdgeInsets.all(16.0), child: Text('Chấm điểm: ${student.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue))), Container(padding: const EdgeInsets.all(16.0), color: Colors.blue.shade50, child: Column(children: [Row(children: [Expanded(child: DropdownButtonFormField<String>(value: selectedSubject, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Môn'), items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (val) => setModalState(() => selectedSubject = val!))), const SizedBox(width: 10), Expanded(child: DropdownButtonFormField<String>(value: selectedType, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Loại'), items: gradeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(), onChanged: (val) => setModalState(() => selectedType = val!)))]), const SizedBox(height: 10), Row(children: [Expanded(child: TextField(controller: scoreController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Điểm số'))), const SizedBox(width: 10), ElevatedButton(onPressed: () { double? sc = double.tryParse(scoreController.text); if (sc != null && sc >= 0 && sc <= 10) { setModalState(() { if (student.grades[selectedSubject] == null) student.grades[selectedSubject] = {'Miệng / 15 Phút': [], '1 Tiết / Giữa Kỳ': [], 'Học Kỳ': []}; student.grades[selectedSubject]![selectedType]!.add(sc); scoreController.clear(); }); setState(() {}); } }, child: const Text('Lưu'))])])), Expanded(child: student.grades.isEmpty ? const Center(child: Text('Chưa có điểm')) : ListView(children: student.grades.entries.map((e) => ExpansionTile(title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)), children: e.value.entries.map((te) => ListTile(title: Text(te.key), trailing: Text(te.value.isEmpty ? '-' : te.value.join(" | ")))).toList())).toList()))]))); }); });
  }

  // ================= CÁC HÀM QUẢN LÝ THỜI KHÓA BIỂU (THÊM PHÂN CÔNG GV) =================
  void _showAddTimetableDialog() {
    final List<String> classes = mockStudents.map((s) => s.className).toSet().toList()..sort();
    String selectedClass = classes.isNotEmpty ? classes.first : '';
    // Lấy danh sách tên giáo viên để phân công
    final List<String> teacherNames = mockTeachers.map((t) => t.name).toList();
    String selectedTeacher = teacherNames.isNotEmpty ? teacherNames.first : '';

    TextEditingController subjectController = TextEditingController();
    TextEditingController timeController = TextEditingController();
    DateTime chosenDate = DateTime.now();
    TextEditingController dateController = TextEditingController(text: "${chosenDate.year}-${chosenDate.month.toString().padLeft(2, '0')}-${chosenDate.day.toString().padLeft(2, '0')}");

    if (classes.isEmpty || teacherNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm Học sinh và Giáo viên trước!')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm Lịch Học Mới', style: TextStyle(color: Colors.blue)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(value: selectedClass, decoration: const InputDecoration(labelText: 'Chọn Lớp'), items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) => setDialogState(() => selectedClass = val!)),
                // NÂNG CẤP: Dropdown phân công giáo viên
                DropdownButtonFormField<String>(value: selectedTeacher, decoration: const InputDecoration(labelText: 'Phân công Giáo viên'), items: teacherNames.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (val) => setDialogState(() => selectedTeacher = val!)),
                TextField(
                  controller: dateController, readOnly: true,
                  decoration: const InputDecoration(labelText: 'Ngày học', suffixIcon: Icon(Icons.calendar_today, color: Colors.blue)),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(context: context, initialDate: chosenDate, firstDate: DateTime(2025), lastDate: DateTime(2030));
                    if (picked != null) { chosenDate = picked; setDialogState(() { dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}"; }); }
                  },
                ),
                TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Môn học')),
                TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Thời gian (VD: 07:00 - 08:30)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(onPressed: () {
              setState(() {
                mockTimetable.add(Lesson(id: DateTime.now().toString(), date: dateController.text, subject: subjectController.text, time: timeController.text, className: selectedClass, teacherName: selectedTeacher));
              });
              Navigator.pop(context);
            }, child: const Text('Lưu'))
          ],
        ),
      ),
    );
  }

  void _showEditTimetableDialog(Lesson lesson) {
    final List<String> classes = mockStudents.map((s) => s.className).toSet().toList()..sort();
    String selectedClass = classes.contains(lesson.className) ? lesson.className : (classes.isNotEmpty ? classes.first : '');
    final List<String> teacherNames = mockTeachers.map((t) => t.name).toList();
    String selectedTeacher = teacherNames.contains(lesson.teacherName) ? lesson.teacherName : (teacherNames.isNotEmpty ? teacherNames.first : '');

    TextEditingController subjectController = TextEditingController(text: lesson.subject);
    TextEditingController timeController = TextEditingController(text: lesson.time);
    TextEditingController dateController = TextEditingController(text: lesson.date);
    DateTime chosenDate = DateTime.parse(lesson.date);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Chỉnh sửa Lịch Học'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(value: selectedClass, decoration: const InputDecoration(labelText: 'Chọn Lớp'), items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) => setDialogState(() => selectedClass = val!)),
                DropdownButtonFormField<String>(value: selectedTeacher, decoration: const InputDecoration(labelText: 'Phân công Giáo viên'), items: teacherNames.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (val) => setDialogState(() => selectedTeacher = val!)),
                TextField(
                  controller: dateController, readOnly: true,
                  decoration: const InputDecoration(labelText: 'Ngày học', suffixIcon: Icon(Icons.calendar_today)),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(context: context, initialDate: chosenDate, firstDate: DateTime(2025), lastDate: DateTime(2030));
                    if (picked != null) { chosenDate = picked; setDialogState(() { dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}"; }); }
                  },
                ),
                TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Môn học')),
                TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Thời gian')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(onPressed: () { setState(() { lesson.date = dateController.text; lesson.subject = subjectController.text; lesson.time = timeController.text; lesson.className = selectedClass; lesson.teacherName = selectedTeacher;}); Navigator.pop(context); }, child: const Text('Cập nhật'))
          ],
        ),
      ),
    );
  }

  void _deleteLesson(Lesson lesson) { setState(() { mockTimetable.removeWhere((l) => l.id == lesson.id); }); }

  void _showAttendanceBottomSheet(BuildContext context, Lesson lesson) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (BuildContext context) { return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) { List<Student> studentsInClass = mockStudents.where((s) => s.className == lesson.className).toList(); String? currentCode = lessonAttendanceCodes[lesson.id]; List<String> attendedList = lessonAttendedStudents[lesson.id] ?? []; return FractionallySizedBox(heightFactor: 0.8, child: Column(children: [Padding(padding: const EdgeInsets.all(16.0), child: Text('Điểm danh: ${lesson.subject}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), Container(width: double.infinity, padding: const EdgeInsets.all(16.0), color: Colors.blue.shade50, child: Column(children: [if (currentCode != null) Text(currentCode, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 5)) else const Text('Chưa mở điểm danh', style: TextStyle(color: Colors.red)), ElevatedButton(onPressed: () { setModalState(() { lessonAttendanceCodes[lesson.id] = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString(); if (lessonAttendedStudents[lesson.id] == null) lessonAttendedStudents[lesson.id] = []; }); }, child: const Text('Tạo mã'))])), Expanded(child: ListView.builder(itemCount: studentsInClass.length, itemBuilder: (context, index) { final student = studentsInClass[index]; final isAttended = attendedList.contains(student.id); return CheckboxListTile(value: isAttended, title: Text(student.name), secondary: Icon(isAttended ? Icons.check_circle : Icons.radio_button_unchecked, color: isAttended ? Colors.green : Colors.grey), onChanged: (val) { setModalState(() { if (val == true) { lessonAttendedStudents[lesson.id]!.add(student.id); } else { lessonAttendedStudents[lesson.id]!.remove(student.id); } }); }); }))])); }); });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> classes = mockStudents.map((s) => s.className).toSet().toList()..sort();

    // TAB 1: DANH SÁCH LỚP HỌC
    Widget studentListTab = Scaffold(
      body: classes.isEmpty ? const Center(child: Text('Chưa có học sinh')) : ListView.builder(
        itemCount: classes.length,
        itemBuilder: (context, classIndex) {
          String currentClass = classes[classIndex]; List<Student> studentsInClass = mockStudents.where((s) => s.className == currentClass).toList();
          return ExpansionTile(
            initiallyExpanded: true, title: Text('Lớp: $currentClass', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            children: studentsInClass.map((student) {
              int originalIndex = mockStudents.indexOf(student);
              return Card(child: ListTile(title: Text(student.name), subtitle: Text('Mã: ${student.id} | Mật khẩu: ${student.password}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.star, color: Colors.amber), onPressed: () => _showGradesBottomSheet(context, student)), IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditStudentDialog(originalIndex)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteStudent(originalIndex))])));
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddStudentDialog, child: const Icon(Icons.add)),
    );

    // TAB 2: QUẢN LÝ GIÁO VIÊN (MỚI)
    Widget teacherListTab = Scaffold(
      body: mockTeachers.isEmpty ? const Center(child: Text('Chưa có giáo viên')) : ListView.builder(
        itemCount: mockTeachers.length,
        itemBuilder: (context, index) {
          Teacher teacher = mockTeachers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.work, color: Colors.white)),
              title: Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Mã GV: ${teacher.id} | SĐT: ${teacher.phone}\nMật khẩu: ${teacher.password}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditTeacherDialog(index)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteTeacher(index)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddTeacherDialog, backgroundColor: Colors.blue, child: const Icon(Icons.add, color: Colors.white)),
    );

    // TAB 3: THỜI KHÓA BIỂU
    Widget timetableTab = DefaultTabController(
      length: daysOfWeek.length,
      child: Scaffold(
        appBar: PreferredSize(preferredSize: const Size.fromHeight(50.0), child: AppBar(bottom: TabBar(isScrollable: true, tabs: daysOfWeek.map((day) => Tab(text: day)).toList()))),
        body: TabBarView(
          children: daysOfWeek.map((day) {
            final lessonsOfDay = mockTimetable.where((l) => _getWeekdayString(l.date) == day).toList()..sort((a, b) => a.time.compareTo(b.time));
            if (lessonsOfDay.isEmpty) return Center(child: Text('Không có lịch học $day'));
            return ListView.builder(
              itemCount: lessonsOfDay.length,
              itemBuilder: (context, index) {
                final lesson = lessonsOfDay[index];
                return Card(
                  child: ListTile(
                    title: Text(lesson.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                    // NÂNG CẤP: Hiển thị tên Giáo viên đang được phân công dạy môn này
                    subtitle: Text('${lesson.time} | Ngày: ${lesson.date} | Lớp: ${lesson.className}\nGiáo viên: ${lesson.teacherName}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.green), onPressed: () => _showAttendanceBottomSheet(context, lesson)), IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditTimetableDialog(lesson)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteLesson(lesson))]),
                  ),
                );
              },
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(onPressed: _showAddTimetableDialog, child: const Icon(Icons.add)),
      ),
    );

    // GỘP 4 TAB CHO ADMIN
    final tabs = [studentListTab, teacherListTab, timetableTab, const EventsAdminTab()];

    return Scaffold(
      appBar: AppBar(title: const Text('Quản Trị Nhà Trường', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Học sinh'),
            BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'Giáo viên'), // THÊM TAB NÀY
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch học'),
            BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Sự kiện'),
          ]
      ),
    );
  }
}