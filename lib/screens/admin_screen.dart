// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
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

  // ================= 1. QUẢN LÝ BẢNG TIN (TÍNH NĂNG MỚI) =================
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
                onPressed: () {
                  setState(() {
                    mockNotifications.insert(0, NotificationPost(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text, content: contentController.text, date: dateController.text, category: selectedCategory
                    ));
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng bản tin thành công!'), backgroundColor: Colors.green));
                },
                child: const Text('Đăng bài', style: TextStyle(color: Colors.white))
            )
          ],
        ),
      ),
    );
  }

  void _showEditNewsDialog(int index) {
    NotificationPost post = mockNotifications[index];
    TextEditingController titleController = TextEditingController(text: post.title);
    TextEditingController contentController = TextEditingController(text: post.content);
    TextEditingController dateController = TextEditingController(text: post.date);
    String selectedCategory = post.category;
    final List<String> categories = ['Chung', 'Học phí', 'Lịch thi', 'Sự kiện'];
    if (!categories.contains(selectedCategory)) selectedCategory = 'Chung';

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
                onPressed: () {
                  setState(() {
                    mockNotifications[index].title = titleController.text;
                    mockNotifications[index].content = contentController.text;
                    mockNotifications[index].date = dateController.text;
                    mockNotifications[index].category = selectedCategory;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green));
                },
                child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white))
            )
          ],
        ),
      ),
    );
  }

  void _deleteNews(int index) {
    setState(() { mockNotifications.removeAt(index); });
  }

  // ================= CÁC HÀM QUẢN LÝ GIÁO VIÊN =================
  void _showAddTeacherDialog() {
    TextEditingController idController = TextEditingController(); TextEditingController nameController = TextEditingController(); TextEditingController phoneController = TextEditingController(); TextEditingController passwordController = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Thêm Giáo Viên Mới', style: TextStyle(color: Colors.blue)), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã GV (VD: GV004)')), TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và Tên')), TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại')), TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), ElevatedButton(onPressed: () { setState(() { mockTeachers.add(Teacher(id: idController.text, name: nameController.text, phone: phoneController.text, password: passwordController.text)); }); Navigator.pop(context); }, child: const Text('Lưu'))]));
  }
  void _showEditTeacherDialog(int index) {
    Teacher teacher = mockTeachers[index]; TextEditingController idController = TextEditingController(text: teacher.id); TextEditingController nameController = TextEditingController(text: teacher.name); TextEditingController phoneController = TextEditingController(text: teacher.phone); TextEditingController passwordController = TextEditingController(text: teacher.password);
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('Sửa Thông Tin Giáo Viên', style: TextStyle(color: Colors.blue)), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã GV')), TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và Tên')), TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại')), TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), ElevatedButton(onPressed: () { setState(() { mockTeachers[index].id = idController.text; mockTeachers[index].name = nameController.text; mockTeachers[index].phone = phoneController.text; mockTeachers[index].password = passwordController.text; }); Navigator.pop(context); }, child: const Text('Cập nhật'))]));
  }
  void _deleteTeacher(int index) { setState(() { mockTeachers.removeAt(index); }); }

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
    List<String> subjects = mockTimetable.where((l) => l.className == student.className).map((l) => l.subject).toSet().toList(); if (subjects.isEmpty) subjects = ['Toán Học', 'Ngữ Văn', 'Tiếng Anh', 'Vật Lý'];
    String selectedSubject = subjects.first; String selectedType = gradeTypes.first; TextEditingController scoreController = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (BuildContext context) { return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) { return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: FractionallySizedBox(heightFactor: 0.8, child: Column(children: [Padding(padding: const EdgeInsets.all(16.0), child: Text('Chấm điểm: ${student.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue))), Container(padding: const EdgeInsets.all(16.0), color: Colors.blue.shade50, child: Column(children: [Row(children: [Expanded(child: DropdownButtonFormField<String>(value: selectedSubject, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Môn'), items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (val) => setModalState(() => selectedSubject = val!))), const SizedBox(width: 10), Expanded(child: DropdownButtonFormField<String>(value: selectedType, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Loại'), items: gradeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(), onChanged: (val) => setModalState(() => selectedType = val!)))]), const SizedBox(height: 10), Row(children: [Expanded(child: TextField(controller: scoreController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Điểm số'))), const SizedBox(width: 10), ElevatedButton(onPressed: () { double? sc = double.tryParse(scoreController.text); if (sc != null && sc >= 0 && sc <= 10) { setModalState(() { if (student.grades[selectedSubject] == null) student.grades[selectedSubject] = {'Miệng / 15 Phút': [], '1 Tiết / Giữa Kỳ': [], 'Học Kỳ': []}; student.grades[selectedSubject]![selectedType]!.add(sc); scoreController.clear(); }); setState(() {}); } }, child: const Text('Lưu'))])])), Expanded(child: student.grades.isEmpty ? const Center(child: Text('Chưa có điểm')) : ListView(children: student.grades.entries.map((e) => ExpansionTile(title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)), children: e.value.entries.map((te) => ListTile(title: Text(te.key), trailing: Text(te.value.isEmpty ? '-' : te.value.join(" | ")))).toList())).toList()))]))); }); });
  }

  // ================= CÁC HÀM QUẢN LÝ THỜI KHÓA BIỂU =================
  void _showAddTimetableDialog() {
    final List<String> classes = mockStudents.map((s) => s.className).toSet().toList()..sort(); String selectedClass = classes.isNotEmpty ? classes.first : ''; final List<String> teacherNames = mockTeachers.map((t) => t.name).toList(); String selectedTeacher = teacherNames.isNotEmpty ? teacherNames.first : ''; TextEditingController subjectController = TextEditingController(); TextEditingController timeController = TextEditingController(); DateTime chosenDate = DateTime.now(); TextEditingController dateController = TextEditingController(text: "${chosenDate.year}-${chosenDate.month.toString().padLeft(2, '0')}-${chosenDate.day.toString().padLeft(2, '0')}");
    if (classes.isEmpty || teacherNames.isEmpty) return;
    showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(title: const Text('Thêm Lịch Học Mới', style: TextStyle(color: Colors.blue)), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButtonFormField<String>(value: selectedClass, decoration: const InputDecoration(labelText: 'Chọn Lớp'), items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) => setDialogState(() => selectedClass = val!)), DropdownButtonFormField<String>(value: selectedTeacher, decoration: const InputDecoration(labelText: 'Phân công Giáo viên'), items: teacherNames.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (val) => setDialogState(() => selectedTeacher = val!)), TextField(controller: dateController, readOnly: true, decoration: const InputDecoration(labelText: 'Ngày học', suffixIcon: Icon(Icons.calendar_today, color: Colors.blue)), onTap: () async { DateTime? picked = await showDatePicker(context: context, initialDate: chosenDate, firstDate: DateTime(2025), lastDate: DateTime(2030)); if (picked != null) { chosenDate = picked; setDialogState(() { dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}"; }); } }), TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Môn học')), TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Thời gian (VD: 07:00 - 08:30)'))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), ElevatedButton(onPressed: () { setState(() { mockTimetable.add(Lesson(id: DateTime.now().toString(), date: dateController.text, subject: subjectController.text, time: timeController.text, className: selectedClass, teacherName: selectedTeacher)); }); Navigator.pop(context); }, child: const Text('Lưu'))])));
  }
  void _showEditTimetableDialog(Lesson lesson) {
    final List<String> classes = mockStudents.map((s) => s.className).toSet().toList()..sort(); String selectedClass = classes.contains(lesson.className) ? lesson.className : (classes.isNotEmpty ? classes.first : ''); final List<String> teacherNames = mockTeachers.map((t) => t.name).toList(); String selectedTeacher = teacherNames.contains(lesson.teacherName) ? lesson.teacherName : (teacherNames.isNotEmpty ? teacherNames.first : ''); TextEditingController subjectController = TextEditingController(text: lesson.subject); TextEditingController timeController = TextEditingController(text: lesson.time); TextEditingController dateController = TextEditingController(text: lesson.date); DateTime chosenDate = DateTime.parse(lesson.date);
    showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(title: const Text('Chỉnh sửa Lịch Học'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [DropdownButtonFormField<String>(value: selectedClass, decoration: const InputDecoration(labelText: 'Chọn Lớp'), items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) => setDialogState(() => selectedClass = val!)), DropdownButtonFormField<String>(value: selectedTeacher, decoration: const InputDecoration(labelText: 'Phân công Giáo viên'), items: teacherNames.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (val) => setDialogState(() => selectedTeacher = val!)), TextField(controller: dateController, readOnly: true, decoration: const InputDecoration(labelText: 'Ngày học', suffixIcon: Icon(Icons.calendar_today)), onTap: () async { DateTime? picked = await showDatePicker(context: context, initialDate: chosenDate, firstDate: DateTime(2025), lastDate: DateTime(2030)); if (picked != null) { chosenDate = picked; setDialogState(() { dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}"; }); } }), TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Môn học')), TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Thời gian'))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')), ElevatedButton(onPressed: () { setState(() { lesson.date = dateController.text; lesson.subject = subjectController.text; lesson.time = timeController.text; lesson.className = selectedClass; lesson.teacherName = selectedTeacher;}); Navigator.pop(context); }, child: const Text('Cập nhật'))])));
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
            initiallyExpanded: true, title: Text('Lớp: $currentClass', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            children: studentsInClass.map((student) {
              int originalIndex = mockStudents.indexOf(student);
              return Card(margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ListTile(leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white)), title: Text(student.name), subtitle: Text('Mã: ${student.id} | MK: ${student.password}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.star, color: Colors.amber), onPressed: () => _showGradesBottomSheet(context, student)), IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditStudentDialog(originalIndex)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteStudent(originalIndex))])));
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddStudentDialog, backgroundColor: Colors.blueAccent, child: const Icon(Icons.add, color: Colors.white)),
    );

    // TAB 2: QUẢN LÝ GIÁO VIÊN
    Widget teacherListTab = Scaffold(
      body: mockTeachers.isEmpty ? const Center(child: Text('Chưa có giáo viên')) : ListView.builder(
        itemCount: mockTeachers.length,
        itemBuilder: (context, index) {
          Teacher teacher = mockTeachers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.work, color: Colors.white)),
              title: Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Mã GV: ${teacher.id} | SĐT: ${teacher.phone}\nMK: ${teacher.password}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditTeacherDialog(index)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteTeacher(index))]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddTeacherDialog, backgroundColor: Colors.indigo, child: const Icon(Icons.add, color: Colors.white)),
    );

    // TAB 3: THỜI KHÓA BIỂU
    Widget timetableTab = DefaultTabController(
      length: daysOfWeek.length,
      child: Scaffold(
        appBar: PreferredSize(preferredSize: const Size.fromHeight(50.0), child: AppBar(backgroundColor: Colors.white, bottom: TabBar(isScrollable: true, tabs: daysOfWeek.map((day) => Tab(text: day)).toList()))),
        body: TabBarView(
          children: daysOfWeek.map((day) {
            final lessonsOfDay = mockTimetable.where((l) => _getWeekdayString(l.date) == day).toList()..sort((a, b) => a.time.compareTo(b.time));
            if (lessonsOfDay.isEmpty) return Center(child: Text('Không có lịch học $day'));
            return ListView.builder(
              itemCount: lessonsOfDay.length,
              itemBuilder: (context, index) {
                final lesson = lessonsOfDay[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.green.shade100, child: const Icon(Icons.menu_book, color: Colors.green)),
                    title: Text(lesson.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${lesson.time} | Ngày: ${lesson.date}\nLớp: ${lesson.className} | GV: ${lesson.teacherName}'),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.green), onPressed: () => _showAttendanceBottomSheet(context, lesson)), IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditTimetableDialog(lesson)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteLesson(lesson))]),
                  ),
                );
              },
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(onPressed: _showAddTimetableDialog, backgroundColor: Colors.green, child: const Icon(Icons.add, color: Colors.white)),
      ),
    );

    // TAB 4: QUẢN LÝ BẢNG TIN THÔNG BÁO
    Widget newsTab = Scaffold(
      body: mockNotifications.isEmpty
          ? const Center(child: Text('Chưa có thông báo nào'))
          : ListView.builder(
        itemCount: mockNotifications.length,
        itemBuilder: (context, index) {
          final post = mockNotifications[index];
          Color catColor = Colors.blue;
          if (post.category == 'Học phí') catColor = Colors.red;
          if (post.category == 'Lịch thi') catColor = Colors.orange;
          if (post.category == 'Sự kiện') catColor = Colors.purple;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: CircleAvatar(backgroundColor: catColor.withOpacity(0.2), child: Icon(Icons.newspaper, color: catColor)),
              title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text('${post.category} • ${post.date}\n${post.content}', maxLines: 2, overflow: TextOverflow.ellipsis),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditNewsDialog(index)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteNews(index)),
                ],
              ),
            ),
          );
        },
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
            BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Bảng tin'), // Tab Bảng tin thay thế Sự kiện
          ]
      ),
    );
  }
}