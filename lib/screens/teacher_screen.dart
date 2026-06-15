// lib/screens/teacher_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/student.dart';
import 'teacher_profile_screen.dart';

class TeacherScreen extends StatefulWidget {
  final Teacher loggedInTeacher;

  const TeacherScreen({super.key, required this.loggedInTeacher});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  int _currentIndex = 0;
  final List<String> gradeTypes = ['Miệng / 15 Phút', '1 Tiết / Giữa Kỳ', 'Học Kỳ'];

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  String _getWeekdayString(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      List<String> weekdays = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];
      return weekdays[dt.weekday - 1];
    } catch (_) {
      return 'Thứ 2';
    }
  }

  void _showAttendanceBottomSheet(BuildContext context, Lesson lesson) {
    showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                      Padding(padding: const EdgeInsets.all(16.0), child: Text('Điểm danh: ${lesson.subject} - Lớp ${lesson.className}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(16.0), color: Colors.blue.shade50,
                        child: Column(
                          children: [
                            if (currentCode != null)
                              Text(currentCode, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 5))
                            else
                              const Text('Chưa mở điểm danh', style: TextStyle(color: Colors.red)),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                                onPressed: () {
                                  setModalState(() {
                                    lessonAttendanceCodes[lesson.id] = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
                                    if (lessonAttendedStudents[lesson.id] == null) lessonAttendedStudents[lesson.id] = [];
                                  });
                                },
                                icon: const Icon(Icons.qr_code),
                                label: const Text('Mở Điểm danh & Tạo mã')
                            )
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
                                value: isAttended, title: Text(student.name),
                                subtitle: Text('Mã HS: ${student.id}'),
                                secondary: Icon(isAttended ? Icons.check_circle : Icons.radio_button_unchecked, color: isAttended ? Colors.green : Colors.grey),
                                onChanged: (val) {
                                  setModalState(() {
                                    if (lessonAttendedStudents[lesson.id] == null) lessonAttendedStudents[lesson.id] = [];
                                    if (val == true) { lessonAttendedStudents[lesson.id]!.add(student.id); }
                                    else { lessonAttendedStudents[lesson.id]!.remove(student.id); }
                                  });
                                }
                            );
                          },
                        ),
                      )
                    ],
                  ),
                );
              }
          );
        }
    );
  }

  void _showGradesBottomSheet(BuildContext context, Student student, List<String> subjectsTaught) {
    if (subjectsTaught.isEmpty) subjectsTaught = ['Môn chung'];
    String selectedSubject = subjectsTaught.first;
    String selectedType = gradeTypes.first;
    TextEditingController scoreController = TextEditingController();

    showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: FractionallySizedBox(
                    heightFactor: 0.8,
                    child: Column(
                      children: [
                        Padding(padding: const EdgeInsets.all(16.0), child: Text('Chấm điểm: ${student.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue))),
                        Container(
                          padding: const EdgeInsets.all(16.0), color: Colors.blue.shade50,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: DropdownButtonFormField<String>(value: selectedSubject, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Môn'), items: subjectsTaught.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (val) => setModalState(() => selectedSubject = val!))),
                                  const SizedBox(width: 10),
                                  Expanded(child: DropdownButtonFormField<String>(value: selectedType, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Loại'), items: gradeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(), onChanged: (val) => setModalState(() => selectedType = val!))),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: TextField(controller: scoreController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Điểm số (0-10)'))),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                      onPressed: () {
                                        double? sc = double.tryParse(scoreController.text);
                                        if (sc != null && sc >= 0 && sc <= 10) {
                                          setModalState(() {
                                            if (student.grades[selectedSubject] == null) student.grades[selectedSubject] = {'Miệng / 15 Phút': [], '1 Tiết / Giữa Kỳ': [], 'Học Kỳ': []};
                                            if (student.grades[selectedSubject]![selectedType] == null) student.grades[selectedSubject]![selectedType] = [];
                                            student.grades[selectedSubject]![selectedType]!.add(sc);
                                            scoreController.clear();
                                          });
                                          setState(() {});
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Điểm không hợp lệ!'), backgroundColor: Colors.red));
                                        }
                                      },
                                      child: const Text('Lưu', style: TextStyle(color: Colors.white))
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: student.grades.isEmpty ? const Center(child: Text('Chưa có điểm')) : ListView(
                            children: student.grades.entries.map((e) => ExpansionTile(title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)), children: e.value.entries.map((te) => ListTile(title: Text(te.key), trailing: Text(te.value.isEmpty ? '-' : te.value.join(" | ")))).toList())).toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  Widget _buildTimetableGrid(List<DateTime> weekDates, List<Lesson> myLessons) {
    const double hourHeight = 50.0; const double dayWidth = 95.0; const double timeColumnWidth = 45.0; const double headerHeight = 40.0;
    const int startHour = 6; const int endHour = 18; const int hourCount = endHour - startHour + 1;
    final List<String> days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            width: timeColumnWidth + days.length * dayWidth, height: headerHeight + hourCount * hourHeight, color: Colors.white,
            child: Stack(
              children: [
                for (int i = 0; i <= hourCount; i++) Positioned(top: headerHeight + i * hourHeight, left: 0, right: 0, child: Container(height: 1, color: Colors.grey[200])),
                for (int i = 0; i <= days.length; i++) Positioned(top: 0, bottom: 0, left: timeColumnWidth + i * dayWidth, child: Container(width: 1, color: Colors.grey[200])),
                for (int i = 0; i < hourCount; i++) Positioned(top: headerHeight + i * hourHeight, left: 0, width: timeColumnWidth, height: hourHeight, child: Center(child: Text('${startHour + i}:00', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)))),

                for (int i = 0; i < days.length; i++)
                  Positioned(
                    top: 0, left: timeColumnWidth + i * dayWidth, width: dayWidth, height: headerHeight,
                    child: Container(
                      color: Colors.blue[50],
                      child: Center(
                        child: Text(
                          '${days[i]}\n(${weekDates[i].day.toString().padLeft(2, '0')}/${weekDates[i].month.toString().padLeft(2, '0')})',
                          textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800], fontSize: 12),
                        ),
                      ),
                    ),
                  ),

                for (var lesson in myLessons)
                  if (weekDates.any((d) => "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}" == lesson.date))
                    _buildLessonBlock(lesson, startHour, hourHeight, dayWidth, timeColumnWidth, headerHeight, weekDates),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonBlock(Lesson lesson, int baseHour, double hHeight, double dWidth, double tWidth, double headerH, List<DateTime> weekDates) {
    try {
      final parts = lesson.time.split('-'); if (parts.length != 2) return const SizedBox.shrink();
      final startH = int.parse(parts[0].trim().split(':')[0]); final startM = int.parse(parts[0].trim().split(':')[1]);
      final endH = int.parse(parts[1].trim().split(':')[0]); final endM = int.parse(parts[1].trim().split(':')[1]);

      int dayIndex = weekDates.indexWhere((d) => "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}" == lesson.date);
      if (dayIndex == -1) return const SizedBox.shrink();

      final top = headerH + ((startH - baseHour) * hHeight) + (startM / 60 * hHeight);
      final height = ((endH - startH) * hHeight) + ((endM - startM) / 60 * hHeight);
      final left = tWidth + dayIndex * dWidth;

      Color bgColor = Colors.blue.shade100; Color borderColor = Colors.blue.shade700;

      return Positioned(
        top: top, left: left, width: dWidth, height: height,
        child: InkWell(
          onTap: () => _showAttendanceBottomSheet(context, lesson),
          child: Container(
            margin: const EdgeInsets.all(2), padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, border: Border(left: BorderSide(color: borderColor, width: 4)), borderRadius: BorderRadius.circular(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${lesson.subject} - Lớp ${lesson.className}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: borderColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4), Text(lesson.time, style: const TextStyle(fontSize: 11, color: Colors.black87)), const Spacer(),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [Icon(Icons.qr_code_scanner, size: 14, color: borderColor)]),
              ],
            ),
          ),
        ),
      );
    } catch (e) { return const SizedBox.shrink(); }
  }


  @override
  Widget build(BuildContext context) {
    // 1. Lọc Lịch dạy: Lấy các tiết học mà giáo viên này được phân công
    final List<Lesson> myLessons = mockTimetable.where((l) => l.teacherName == widget.loggedInTeacher.name).toList();

    // 2. Lấy danh sách các lớp và các môn mà giáo viên này dạy
    final List<String> myClasses = myLessons.map((l) => l.className).toSet().toList()..sort();
    final List<String> mySubjects = myLessons.map((l) => l.subject).toSet().toList();

    // TAB 1: DANH SÁCH LỚP
    Widget myClassesTab = Scaffold(
      body: myClasses.isEmpty ? const Center(child: Text('Bạn chưa được phân công dạy lớp nào.')) : ListView.builder(
        itemCount: myClasses.length,
        itemBuilder: (context, classIndex) {
          String currentClass = myClasses[classIndex];
          List<Student> studentsInClass = mockStudents.where((s) => s.className == currentClass).toList();

          // NÂNG CẤP: Tìm các lịch dạy của lớp này và ghép lại thành chuỗi hiển thị
          List<Lesson> classLessons = myLessons.where((l) => l.className == currentClass).toList();
          String scheduleInfo = classLessons.map((l) => '• ${l.subject} (${_getWeekdayString(l.date)}, ${l.date} | ${l.time})').join('\n');
          if (scheduleInfo.isEmpty) scheduleInfo = 'Chưa phân bổ lịch';

          return ExpansionTile(
            initiallyExpanded: true, leading: const Icon(Icons.class_, color: Colors.blue),
            title: Text('Lớp: $currentClass', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18)),

            // NÂNG CẤP PHẦN SUBTITLE: Hiển thị sĩ số và Lịch học của lớp
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text('Sĩ số: ${studentsInClass.length} học sinh', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Lịch dạy của bạn:', style: TextStyle(color: Colors.blueGrey, fontSize: 13, fontStyle: FontStyle.italic)),
                const SizedBox(height: 3),
                Text(scheduleInfo, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4)),
                const SizedBox(height: 5),
              ],
            ),

            children: studentsInClass.map((student) {
              return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.blue.shade100, child: const Icon(Icons.person, color: Colors.blue)),
                    title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Mã HS: ${student.id}'),
                    trailing: IconButton(
                        icon: const Icon(Icons.star, color: Colors.amber, size: 30),
                        tooltip: 'Chấm điểm',
                        onPressed: () => _showGradesBottomSheet(context, student, mySubjects)
                    ),
                  )
              );
            }).toList(),
          );
        },
      ),
    );

    // TAB 2: LỊCH DẠY CỦA TÔI
    DateTime startOfWeek = _selectedDay!.subtract(Duration(days: _selectedDay!.weekday - 1));
    List<DateTime> weekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    Widget myScheduleTab = Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))]
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1), lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay, calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) { setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; }); },
            onFormatChanged: (format) { setState(() { _calendarFormat = format; }); },
            onPageChanged: (focusedDay) { _focusedDay = focusedDay; },
            calendarStyle: const CalendarStyle(selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true, titleCentered: true,
              formatButtonDecoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.all(Radius.circular(12.0))),
              formatButtonTextStyle: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Expanded(child: _buildTimetableGrid(weekDates, myLessons)),
      ],
    );

    final tabs = [myClassesTab, myScheduleTab];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Không gian Giáo viên', style: TextStyle(color: Colors.white, fontSize: 18)),
            Text('GV: ${widget.loggedInTeacher.name}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        backgroundColor: Colors.blue[800],
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TeacherProfileScreen(teacher: widget.loggedInTeacher)
                  )
              ).then((value) {
                setState(() {}); // Tải lại dữ liệu (tên, SĐT mới) khi quay lại
              });
            },
            child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Row(
                    children: [
                      const Icon(Icons.account_circle, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                          widget.loggedInTeacher.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                      )
                    ]
                )
            ),
          )
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blue[800],
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Lớp đang dạy'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch dạy của tôi'),
          ]
      ),
    );
  }
}