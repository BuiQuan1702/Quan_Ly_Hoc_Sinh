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
  final List<String> daysOfWeek = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
  // Cấu hình các loại điểm và hệ số
  final List<String> gradeTypes = ['Miệng / 15 Phút', '1 Tiết / Giữa Kỳ', 'Học Kỳ'];

  // ================= CÁC HÀM QUẢN LÝ HỌC SINH =================
  void _showAddStudentDialog() {
    TextEditingController idController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController classController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm Học Sinh Mới', style: TextStyle(color: Colors.blue)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã HS (VD: HS004)')),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và Tên')),
                TextField(controller: classController, decoration: const InputDecoration(labelText: 'Lớp (VD: 10A1)')),
                TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                setState(() { mockStudents.add(Student(id: idController.text, name: nameController.text, className: classController.text, password: passwordController.text)); });
                Navigator.pop(context);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showEditStudentDialog(int index) {
    Student student = mockStudents[index];
    TextEditingController idController = TextEditingController(text: student.id);
    TextEditingController nameController = TextEditingController(text: student.name);
    TextEditingController classController = TextEditingController(text: student.className);
    TextEditingController passwordController = TextEditingController(text: student.password);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chỉnh Sửa Thông Tin', style: TextStyle(color: Colors.blue)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: idController, decoration: const InputDecoration(labelText: 'Mã HS')),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Họ và Tên')),
                TextField(controller: classController, decoration: const InputDecoration(labelText: 'Lớp')),
                TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Mật khẩu')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                setState(() {
                  mockStudents[index].id = idController.text;
                  mockStudents[index].name = nameController.text;
                  mockStudents[index].className = classController.text;
                  mockStudents[index].password = passwordController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Cập nhật', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteStudent(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa học sinh "${mockStudents[index].name}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              setState(() { mockStudents.removeAt(index); });
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ================= BẢNG ĐIỀU KHIỂN NHẬP ĐIỂM =================
  void _showGradesBottomSheet(BuildContext context, Student student) {
    List<String> subjects = mockTimetable.where((l) => l.className == student.className).map((l) => l.subject).toSet().toList();
    if (subjects.isEmpty) subjects = ['Toán Học', 'Ngữ Văn', 'Tiếng Anh', 'Vật Lý', 'Hóa Học'];

    String selectedSubject = subjects.first;
    String selectedType = gradeTypes.first; // Mặc định là 15 Phút
    TextEditingController scoreController = TextEditingController();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: FractionallySizedBox(
                    heightFactor: 0.8, // Tăng chiều cao lên 80% để chứa nhiều form hơn
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Chấm điểm: ${student.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ),

                        Container(
                          padding: const EdgeInsets.all(16.0),
                          color: Colors.blue.shade50,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedSubject,
                                      decoration: const InputDecoration(labelText: 'Chọn môn', border: OutlineInputBorder()),
                                      items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                                      onChanged: (val) { setModalState(() => selectedSubject = val!); },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedType,
                                      decoration: const InputDecoration(labelText: 'Loại điểm', border: OutlineInputBorder()),
                                      items: gradeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                                      onChanged: (val) { setModalState(() => selectedType = val!); },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: scoreController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Nhập số điểm (0 - 10)', border: OutlineInputBorder()),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(100, 55)),
                                    onPressed: () {
                                      double? score = double.tryParse(scoreController.text);
                                      if (score != null && score >= 0 && score <= 10) {
                                        setModalState(() {
                                          if (student.grades[selectedSubject] == null) {
                                            student.grades[selectedSubject] = {'Miệng / 15 Phút': [], '1 Tiết / Giữa Kỳ': [], 'Học Kỳ': []};
                                          }
                                          if (student.grades[selectedSubject]![selectedType] == null) {
                                            student.grades[selectedSubject]![selectedType] = [];
                                          }
                                          student.grades[selectedSubject]![selectedType]!.add(score);
                                          scoreController.clear();
                                        });
                                        setState(() {});
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Điểm không hợp lệ!'), backgroundColor: Colors.red));
                                      }
                                    },
                                    icon: const Icon(Icons.add, color: Colors.white),
                                    label: const Text('Lưu điểm', style: TextStyle(color: Colors.white)),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(10),
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Text('Chi tiết điểm các môn', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: student.grades.isEmpty
                              ? const Center(child: Text('Chưa có dữ liệu điểm'))
                              : ListView(
                            children: student.grades.entries.map((entry) {
                              String subjectName = entry.key;
                              var pointsMap = entry.value;
                              return ExpansionTile(
                                leading: const Icon(Icons.assignment, color: Colors.blue),
                                title: Text(subjectName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                children: pointsMap.entries.map((typeEntry) {
                                  return ListTile(
                                    title: Text(typeEntry.key, style: const TextStyle(fontSize: 14)),
                                    trailing: Text(
                                        typeEntry.value.isEmpty ? "Chưa có" : typeEntry.value.join("  |  "),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)
                                    ),
                                  );
                                }).toList(),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  // ================= CÁC HÀM QUẢN LÝ THỜI KHÓA BIỂU & ĐIỂM DANH =================
  // (Các hàm Thời khóa biểu được giữ nguyên)
  void _showAddTimetableDialog() {
    String selectedDay = daysOfWeek.first;
    final List<String> classes = mockStudents.map((s) => s.className).toSet().toList();
    classes.sort();
    String selectedClass = classes.isNotEmpty ? classes.first : '';
    TextEditingController subjectController = TextEditingController();
    TextEditingController timeController = TextEditingController();

    if (classes.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Thêm Lịch Học', style: TextStyle(color: Colors.blue)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(value: selectedClass, decoration: const InputDecoration(labelText: 'Chọn Lớp'), items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) { setDialogState(() => selectedClass = val!); }),
                      DropdownButtonFormField<String>(value: selectedDay, decoration: const InputDecoration(labelText: 'Ngày học'), items: daysOfWeek.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(), onChanged: (val) { setDialogState(() => selectedDay = val!); }),
                      TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Môn học')),
                      TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Thời gian')),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                  ElevatedButton(
                    onPressed: () {
                      setState(() { mockTimetable.add(Lesson(id: DateTime.now().toString(), day: selectedDay, subject: subjectController.text, time: timeController.text, className: selectedClass)); });
                      Navigator.pop(context);
                    },
                    child: const Text('Lưu'),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  void _showEditTimetableDialog(Lesson lesson) {
    String selectedDay = lesson.day;
    final List<String> classes = mockStudents.map((s) => s.className).toSet().toList();
    classes.sort();
    String selectedClass = classes.contains(lesson.className) ? lesson.className : (classes.isNotEmpty ? classes.first : '');
    TextEditingController subjectController = TextEditingController(text: lesson.subject);
    TextEditingController timeController = TextEditingController(text: lesson.time);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Chỉnh sửa Lịch Học', style: TextStyle(color: Colors.blue)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(value: selectedClass, decoration: const InputDecoration(labelText: 'Chọn Lớp'), items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) { setDialogState(() => selectedClass = val!); }),
                      DropdownButtonFormField<String>(value: selectedDay, decoration: const InputDecoration(labelText: 'Ngày học'), items: daysOfWeek.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(), onChanged: (val) { setDialogState(() => selectedDay = val!); }),
                      TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Môn học')),
                      TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Thời gian')),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () {
                      setState(() { lesson.day = selectedDay; lesson.subject = subjectController.text; lesson.time = timeController.text; lesson.className = selectedClass; });
                      Navigator.pop(context);
                    },
                    child: const Text('Cập nhật', style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  void _deleteLesson(Lesson lesson) {
    setState(() { mockTimetable.removeWhere((l) => l.id == lesson.id); });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa lịch học!')));
  }

  void _showAttendanceBottomSheet(BuildContext context, Lesson lesson) {
    showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                List<Student> studentsInClass = mockStudents.where((s) => s.className == lesson.className).toList();
                String? currentCode = lessonAttendanceCodes[lesson.id];
                List<String> attendedList = lessonAttendedStudents[lesson.id] ?? [];

                return FractionallySizedBox(
                  heightFactor: 0.8,
                  child: Column(
                    children: [
                      Padding(padding: const EdgeInsets.all(16.0), child: Text('Điểm danh: ${lesson.subject} - Lớp ${lesson.className}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue))),
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(16.0), color: Colors.blue.shade50,
                        child: Column(
                          children: [
                            if (currentCode != null) ...[
                              const Text('MÃ ĐIỂM DANH', style: TextStyle(fontSize: 14)),
                              Text(currentCode, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 5)),
                            ] else const Text('Chưa mở điểm danh', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                setModalState(() {
                                  lessonAttendanceCodes[lesson.id] = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
                                  if (lessonAttendedStudents[lesson.id] == null) lessonAttendedStudents[lesson.id] = [];
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text(currentCode == null ? 'Mở điểm danh & Tạo mã' : 'Tạo mã mới'),
                            ),
                          ],
                        ),
                      ),
                      Container(padding: const EdgeInsets.all(10), width: double.infinity, color: Colors.grey.shade200, child: Text('Danh sách học sinh (${attendedList.length}/${studentsInClass.length})', style: const TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                        child: ListView.builder(
                          itemCount: studentsInClass.length,
                          itemBuilder: (context, index) {
                            final student = studentsInClass[index];
                            final isAttended = attendedList.contains(student.id);
                            return CheckboxListTile(
                              value: isAttended, activeColor: Colors.green, title: Text(student.name, style: TextStyle(fontWeight: isAttended ? FontWeight.bold : FontWeight.normal)), subtitle: Text('Mã HS: ${student.id}'),
                              secondary: Icon(isAttended ? Icons.check_circle : Icons.radio_button_unchecked, color: isAttended ? Colors.green : Colors.grey),
                              onChanged: (bool? value) {
                                setModalState(() {
                                  if (lessonAttendedStudents[lesson.id] == null) lessonAttendedStudents[lesson.id] = [];
                                  if (value == true) { if (!lessonAttendedStudents[lesson.id]!.contains(student.id)) lessonAttendedStudents[lesson.id]!.add(student.id); } else { lessonAttendedStudents[lesson.id]!.remove(student.id); }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> classes = mockStudents.map((s) => s.className).toSet().toList();
    classes.sort();

    Widget studentListTab = Scaffold(
      body: classes.isEmpty ? const Center(child: Text('Chưa có học sinh nào')) : ListView.builder(
        itemCount: classes.length,
        itemBuilder: (context, classIndex) {
          String currentClass = classes[classIndex];
          List<Student> studentsInClass = mockStudents.where((s) => s.className == currentClass).toList();
          return ExpansionTile(
            initiallyExpanded: true, leading: const Icon(Icons.class_, color: Colors.blue), title: Text('Lớp: $currentClass', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18)), subtitle: Text('Sĩ số: ${studentsInClass.length} học sinh'),
            children: studentsInClass.map((student) {
              int originalIndex = mockStudents.indexOf(student);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5), elevation: 1,
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blue.shade100, child: const Icon(Icons.person, color: Colors.blue)),
                  title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Mã: ${student.id} | Mật khẩu: ${student.password}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.star, color: Colors.amber), tooltip: 'Chấm điểm', onPressed: () => _showGradesBottomSheet(context, student)),
                      IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditStudentDialog(originalIndex)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteStudent(originalIndex)),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddStudentDialog, backgroundColor: Colors.blue, child: const Icon(Icons.add, color: Colors.white)),
    );

    Widget timetableTab = DefaultTabController(
      length: daysOfWeek.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: AppBar(backgroundColor: Colors.white, elevation: 1, bottom: TabBar(isScrollable: true, labelColor: Colors.blue, unselectedLabelColor: Colors.grey, indicatorColor: Colors.blue, tabs: daysOfWeek.map((day) => Tab(text: day)).toList())),
        ),
        body: TabBarView(
          children: daysOfWeek.map((day) {
            final lessonsOfDay = mockTimetable.where((l) => l.day == day).toList();
            if (lessonsOfDay.isEmpty) return Center(child: Text('Không có lịch học $day', style: const TextStyle(color: Colors.grey)));
            lessonsOfDay.sort((a, b) => a.time.compareTo(b.time));

            return ListView.builder(
              padding: const EdgeInsets.all(10), itemCount: lessonsOfDay.length,
              itemBuilder: (context, index) {
                final lesson = lessonsOfDay[index];
                return Card(
                  elevation: 2, margin: const EdgeInsets.only(bottom: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.schedule, color: Colors.blue)),
                    title: Text(lesson.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), subtitle: Text('${lesson.time} | Lớp: ${lesson.className}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.green), tooltip: 'Điểm danh', onPressed: () => _showAttendanceBottomSheet(context, lesson)),
                        IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showEditTimetableDialog(lesson)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteLesson(lesson)),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(onPressed: _showAddTimetableDialog, backgroundColor: Colors.blue, child: const Icon(Icons.add, color: Colors.white)),
      ),
    );

    final tabs = [studentListTab, timetableTab];

    return Scaffold(
      appBar: AppBar(title: const Text('Admin: Quản lý', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, selectedItemColor: Colors.blue, onTap: (index) => setState(() => _currentIndex = index),
        items: const [ BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Lớp học'), BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch học') ],
      ),
    );
  }
}