// lib/screens/user_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/student.dart';
import 'edit_profile_screen.dart';
import 'events_user_tab.dart'; // KHÔI PHỤC IMPORT TAB SỰ KIỆN USER

class UserScreen extends StatefulWidget {
  final Student loggedInStudent;
  const UserScreen({super.key, required this.loggedInStudent});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _currentIndex = 0;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  void _showStudentAttendanceDialog(BuildContext context, Lesson lesson) {
    TextEditingController codeController = TextEditingController(); String myId = widget.loggedInStudent.id;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            bool hasAttended = (lessonAttendedStudents[lesson.id] ?? []).contains(myId);
            return AlertDialog(
              title: Text('Điểm danh: ${lesson.subject}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Thời gian: ${lesson.time}'),
                  if (hasAttended) const Text('ĐÃ ĐIỂM DANH', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                  else TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Nhập mã')),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
                if (!hasAttended) ElevatedButton(onPressed: () {
                  if (codeController.text == lessonAttendanceCodes[lesson.id]) {
                    setState(() { lessonAttendedStudents[lesson.id] ??= []; lessonAttendedStudents[lesson.id]!.add(myId); }); Navigator.pop(context);
                  }
                }, child: const Text('Xác nhận'))
              ],
            );
          }
      ),
    );
  }

  Widget _buildTimetableGrid(List<DateTime> weekDates) {
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

                for (var lesson in mockTimetable.where((l) => l.className == widget.loggedInStudent.className))
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
      if (lesson.subject.toLowerCase().contains('tiếng anh')) { bgColor = Colors.orange.shade100; borderColor = Colors.orange.shade700; }
      else if (lesson.subject.toLowerCase().contains('.net') || lesson.subject.toLowerCase().contains('vật lý')) { bgColor = Colors.red.shade100; borderColor = Colors.red.shade700; }

      return Positioned(
        top: top, left: left, width: dWidth, height: height,
        child: InkWell(
          onTap: () => _showStudentAttendanceDialog(context, lesson),
          child: Container(
            margin: const EdgeInsets.all(2), padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, border: Border(left: BorderSide(color: borderColor, width: 4)), borderRadius: BorderRadius.circular(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson.subject, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: borderColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4), Text(lesson.time, style: const TextStyle(fontSize: 11, color: Colors.black87)), const Spacer(),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [Icon(Icons.touch_app, size: 14, color: borderColor)]),
              ],
            ),
          ),
        ),
      );
    } catch (e) { return const SizedBox.shrink(); }
  }

  @override
  Widget build(BuildContext context) {
    final List<Student> classmates = mockStudents.where((s) => s.className == widget.loggedInStudent.className).toList();

    Widget studentListTab = ListView.builder(
      itemCount: classmates.length,
      itemBuilder: (context, index) => Card(child: ListTile(title: Text(classmates[index].name), subtitle: Text('Mã HS: ${classmates[index].id}'))),
    );

    DateTime startOfWeek = _selectedDay!.subtract(Duration(days: _selectedDay!.weekday - 1));
    List<DateTime> weekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    Widget timetableTab = Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2025, 1, 1), lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay, calendarFormat: _calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) { setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; }); },
          onFormatChanged: (format) { setState(() { _calendarFormat = format; }); },
          onPageChanged: (focusedDay) { _focusedDay = focusedDay; },
          calendarStyle: const CalendarStyle(selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
        ),
        Expanded(child: _buildTimetableGrid(weekDates)),
      ],
    );

    // ================= TAB BẢNG ĐIỂM (HỆ SỐ) =================
    double totalGpa = 0;
    int subjectCount = 0;

    widget.loggedInStudent.grades.forEach((subject, gradeTypes) {
      double sum15m = (gradeTypes['Miệng / 15 Phút'] ?? []).fold(0, (prev, curr) => prev + curr);
      int count15m = (gradeTypes['Miệng / 15 Phút'] ?? []).length;
      double sum1t = (gradeTypes['1 Tiết / Giữa Kỳ'] ?? []).fold(0, (prev, curr) => prev + curr);
      int count1t = (gradeTypes['1 Tiết / Giữa Kỳ'] ?? []).length;
      double sumHk = (gradeTypes['Học Kỳ'] ?? []).fold(0, (prev, curr) => prev + curr);
      int countHk = (gradeTypes['Học Kỳ'] ?? []).length;

      int totalWeights = count15m * 1 + count1t * 2 + countHk * 3;
      if (totalWeights > 0) {
        double subjectAvg = (sum15m * 1 + sum1t * 2 + sumHk * 3) / totalWeights;
        totalGpa += subjectAvg;
        subjectCount++;
      }
    });

    double finalGpa = subjectCount > 0 ? totalGpa / subjectCount : 0.0;

    Widget gradesTab = Column(
      children: [
        Container(
          width: double.infinity, margin: const EdgeInsets.all(15), padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.green, Colors.teal]), borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))]),
          child: Column(
            children: [
              const Text('ĐIỂM TRUNG BÌNH (GPA)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(finalGpa.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5), child: Align(alignment: Alignment.centerLeft, child: Text('Chi tiết điểm các môn:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
        Expanded(
          child: widget.loggedInStudent.grades.isEmpty
              ? const Center(child: Text('Bạn chưa có điểm số nào', style: TextStyle(color: Colors.grey)))
              : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: widget.loggedInStudent.grades.entries.map((entry) {
              var types = entry.value;
              double s15 = (types['Miệng / 15 Phút'] ?? []).fold(0, (p, c) => p + c); int c15 = (types['Miệng / 15 Phút'] ?? []).length;
              double s1t = (types['1 Tiết / Giữa Kỳ'] ?? []).fold(0, (p, c) => p + c); int c1t = (types['1 Tiết / Giữa Kỳ'] ?? []).length;
              double sHk = (types['Học Kỳ'] ?? []).fold(0, (p, c) => p + c); int cHk = (types['Học Kỳ'] ?? []).length;
              int wTotal = c15 * 1 + c1t * 2 + cHk * 3;
              double subAvg = wTotal > 0 ? (s15 * 1 + s1t * 2 + sHk * 3) / wTotal : 0.0;

              return Card(
                elevation: 1, margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  leading: CircleAvatar(backgroundColor: subAvg >= 8.0 ? Colors.green.shade100 : (subAvg >= 5.0 ? Colors.orange.shade100 : Colors.red.shade100), child: Icon(Icons.book, color: subAvg >= 8.0 ? Colors.green : (subAvg >= 5.0 ? Colors.orange : Colors.red))),
                  title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text(wTotal > 0 ? subAvg.toStringAsFixed(1) : '-', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: subAvg >= 8.0 ? Colors.green : (subAvg >= 5.0 ? Colors.orange : Colors.red))),
                  children: types.entries.map((tEntry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tEntry.key, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          Text(tEntry.value.isEmpty ? '-' : tEntry.value.join(", "), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );

    // KHÔI PHỤC ĐỦ 4 TAB CỐ ĐỊNH CHO HỌC SINH
    final tabs = [studentListTab, timetableTab, gradesTab, const EventsUserTab()];

    return Scaffold(
      appBar: AppBar(
        title: Text('Học Sinh - Lớp ${widget.loggedInStudent.className}'),
        backgroundColor: Colors.green,
        // ĐÃ KHÔI PHỤC: Nút bấm mở giao diện chỉnh sửa hồ sơ
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditProfileScreen(student: widget.loggedInStudent)
                  )
              ).then((value) {
                setState(() {}); // Tải lại dữ liệu (tên, mật khẩu mới) khi quay lại
              });
            },
            child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Row(
                    children: [
                      const Icon(Icons.account_circle, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                          widget.loggedInStudent.name,
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
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Lớp học'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Lịch học'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Bảng điểm'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Sự kiện'),
        ],
      ),
    );
  }
}