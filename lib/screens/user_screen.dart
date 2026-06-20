// lib/screens/user_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm Firebase
import '../models/student.dart';
import 'edit_profile_screen.dart';
import 'events_user_tab.dart';
import 'leave_request_student_screen.dart';
import 'news_feed_screen.dart';
import 'assignment_student_screen.dart';

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

  // Tạo Stream để lắng nghe danh sách bạn cùng lớp từ Firestore
  Stream<List<Student>> _getClassmates() {
    return FirebaseFirestore.instance
        .collection('students')
        .where('className', isEqualTo: widget.loggedInStudent.className)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Student(
                  id: doc['id'],
                  name: doc['name'],
                  className: doc['className'],
                  password: doc['password'],
                ))
            .toList());
  }

  // ================= BẢNG NHẬP MÃ ĐIỂM DANH (FIREBASE) =================
  void _showStudentAttendanceDialog(BuildContext context, Lesson lesson) {
    TextEditingController codeController = TextEditingController();
    String myId = widget.loggedInStudent.id;

    showDialog(
      context: context,
      builder: (context) => StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('timetable').doc(lesson.id).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            var lessonData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            String? correctCode = lessonData['attendanceCode'];
            List<dynamic> attendedStudents = lessonData['attendedStudents'] ?? [];
            bool hasAttended = attendedStudents.contains(myId);

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Column(
                children: [
                  Icon(hasAttended ? Icons.check_circle : Icons.qr_code_scanner,
                      size: 50, color: hasAttended ? Colors.green : Colors.blueAccent),
                  const SizedBox(height: 10),
                  Text('Điểm danh', style: TextStyle(color: hasAttended ? Colors.green : Colors.blueAccent, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(lesson.subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 5),
                  Text('Thời gian: ${lesson.time}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  if (hasAttended)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(30)),
                      child: const Text('ĐÃ ĐIỂM DANH THÀNH CÔNG', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    )
                  else
                    TextField(
                        controller: codeController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 5),
                        decoration: InputDecoration(
                            hintText: '----',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
                        )
                    ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng', style: TextStyle(color: Colors.grey))),
                if (!hasAttended)
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                      ),
                      onPressed: () async {
                        if (codeController.text == correctCode) {
                          await FirebaseFirestore.instance.collection('timetable').doc(lesson.id).update({
                            'attendedStudents': FieldValue.arrayUnion([myId])
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Điểm danh thành công!'), backgroundColor: Colors.green));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mã không hợp lệ!'), backgroundColor: Colors.redAccent));
                        }
                      },
                      child: const Text('Xác nhận', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  )
              ],
            );
          }
      ),
    );
  }

  // Tạo Stream để lấy thời khóa biểu của lớp từ Firestore
  Stream<List<Lesson>> _getTimetable() {
    return FirebaseFirestore.instance
        .collection('timetable')
        .where('className', isEqualTo: widget.loggedInStudent.className)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Lesson(
                  id: doc.id,
                  subject: doc['subject'],
                  date: doc['date'],
                  time: doc['time'],
                  className: doc['className'],
                  teacherName: doc['teacherName'],
                ))
            .toList());
  }

  // ================= LƯỚI THỜI KHÓA BIỂU ĐẸP MẮT =================
  Widget _buildTimetableGrid(List<DateTime> weekDates) {
    const double hourHeight = 65.0;
    const double dayWidth = 110.0;
    const double timeColumnWidth = 55.0;
    const double headerHeight = 55.0;
    const int startHour = 6; const int endHour = 18; const int hourCount = endHour - startHour + 1;
    final List<String> days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];

    return StreamBuilder<List<Lesson>>(
      stream: _getTimetable(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final lessons = snapshot.data ?? [];

        return Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: timeColumnWidth + days.length * dayWidth,
                height: headerHeight + hourCount * hourHeight,
                color: const Color(0xFFF9FAFC),
                child: Stack(
                  children: [
                    for (int i = 0; i <= hourCount; i++)
                      Positioned(top: headerHeight + i * hourHeight, left: 0, right: 0, child: Container(height: 1, color: Colors.grey.shade200)),
                    for (int i = 0; i <= days.length; i++)
                      Positioned(top: 0, bottom: 0, left: timeColumnWidth + i * dayWidth, child: Container(width: 1, color: Colors.grey.shade200)),
                    for (int i = 0; i < hourCount; i++)
                      Positioned(top: headerHeight + i * hourHeight, left: 0, width: timeColumnWidth, height: hourHeight, child: Center(child: Text('${startHour + i}:00', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)))),
                    for (int i = 0; i < days.length; i++)
                      Positioned(
                        top: 0, left: timeColumnWidth + i * dayWidth, width: dayWidth, height: headerHeight,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.blue.shade50, border: Border(bottom: BorderSide(color: Colors.blue.shade100, width: 2))),
                          child: Center(
                            child: Text('${days[i]}\n${weekDates[i].day.toString().padLeft(2, '0')}/${weekDates[i].month.toString().padLeft(2, '0')}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800, fontSize: 12)),
                          ),
                        ),
                      ),
                    for (var lesson in lessons)
                      if (weekDates.any((d) => "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}" == lesson.date))
                        _buildLessonBlock(lesson, startHour, hourHeight, dayWidth, timeColumnWidth, headerHeight, weekDates),
                  ],
                ),
              ),
            ),
          ),
        );
      }
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

      Color bgColor = Colors.blue.shade50; Color borderColor = Colors.blueAccent; Color iconColor = Colors.blueAccent;
      if (lesson.subject.toLowerCase().contains('anh')) { bgColor = Colors.orange.shade50; borderColor = Colors.orange; iconColor = Colors.orange; }
      else if (lesson.subject.toLowerCase().contains('lý') || lesson.subject.toLowerCase().contains('.net')) { bgColor = Colors.pink.shade50; borderColor = Colors.pinkAccent; iconColor = Colors.pinkAccent; }

      return Positioned(
        top: top, left: left, width: dWidth, height: height,
        child: InkWell(
          onTap: () => _showStudentAttendanceDialog(context, lesson),
          child: Container(
            margin: const EdgeInsets.all(3), padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: bgColor,
                border: Border(left: BorderSide(color: borderColor, width: 4)),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(2, 2))]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lesson.subject, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(lesson.time, style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                const Spacer(),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [Icon(Icons.touch_app, size: 14, color: iconColor)]),
              ],
            ),
          ),
        ),
      );
    } catch (e) { return const SizedBox.shrink(); }
  }

  @override
  Widget build(BuildContext context) {
    // ================= TAB 1: DANH SÁCH LỚP (SỬ DỤNG FIREBASE) =================
    Widget studentListTab = StreamBuilder<List<Student>>(
      stream: _getClassmates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final classmates = snapshot.data ?? [];
        
        return Column(
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Column(
                children: [
                  Text('LỚP CỦA TÔI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey.shade500)),
                  Text(widget.loggedInStudent.className, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
                  Text('Sĩ số: ${classmates.length} học sinh', style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: classmates.isEmpty 
                ? const Center(child: Text('Không có dữ liệu học sinh trên Firebase'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: classmates.length,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          leading: CircleAvatar(backgroundColor: Colors.blueAccent.withOpacity(0.1), child: const Icon(Icons.person, color: Colors.blueAccent)),
                          title: Text(classmates[index].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Mã HS: ${classmates[index].id}', style: TextStyle(color: Colors.grey.shade600))
                      ),
                    ),
                  ),
            ),
          ],
        );
      }
    );

    // ================= TAB 2: THỜI KHÓA BIỂU =================
    DateTime startOfWeek = _selectedDay!.subtract(Duration(days: _selectedDay!.weekday - 1));
    List<DateTime> weekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
    Widget timetableTab = Column(
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
          child: TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1), lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay, calendarFormat: _calendarFormat, startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) { setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; }); },
            onFormatChanged: (format) { setState(() { _calendarFormat = format; }); },
            onPageChanged: (focusedDay) { _focusedDay = focusedDay; },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: Colors.lightBlueAccent, shape: BoxShape.circle),
            ),
          ),
        ),
        Expanded(child: _buildTimetableGrid(weekDates)),
      ],
    );

    // ================= TAB 3: BẢNG ĐIỂM (FIREBASE) =================
    Widget gradesTab = StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('students').where('id', isEqualTo: widget.loggedInStudent.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return const Center(child: Text('Không tìm thấy dữ liệu học sinh'));

        var studentDoc = snapshot.data!.docs.first;
        var studentData = studentDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> grades = studentData['grades'] ?? {};

        double totalGpa = 0; int subjectCount = 0;
        grades.forEach((subject, gradeTypes) {
          Map<String, dynamic> types = gradeTypes as Map<String, dynamic>;
          double sum15m = (types['Miệng / 15 Phút'] ?? []).fold(0.0, (prev, curr) => prev + (curr as num).toDouble());
          int count15m = (types['Miệng / 15 Phút'] ?? []).length;
          double sum1t = (types['1 Tiết / Giữa Kỳ'] ?? []).fold(0.0, (prev, curr) => prev + (curr as num).toDouble());
          int count1t = (types['1 Tiết / Giữa Kỳ'] ?? []).length;
          double sumHk = (types['Học Kỳ'] ?? []).fold(0.0, (prev, curr) => prev + (curr as num).toDouble());
          int countHk = (types['Học Kỳ'] ?? []).length;
          
          int totalWeights = count15m * 1 + count1t * 2 + countHk * 3;
          if (totalWeights > 0) {
            double subjectAvg = (sum15m * 1 + sum1t * 2 + sumHk * 3) / totalWeights;
            totalGpa += subjectAvg;
            subjectCount++;
          }
        });
        double finalGpa = subjectCount > 0 ? totalGpa / subjectCount : 0.0;

        return Column(
          children: [
            Container(
              width: double.infinity, margin: const EdgeInsets.all(16), padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))]
              ),
              child: Column(
                children: [
                  const Text('ĐIỂM TRUNG BÌNH (GPA)', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Text(finalGpa.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10), child: Align(alignment: Alignment.centerLeft, child: Text('Chi tiết điểm các môn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)))),
            Expanded(
              child: grades.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.assessment_outlined, size: 60, color: Colors.grey.shade300), const SizedBox(height: 10), const Text('Chưa có điểm số nào', style: TextStyle(color: Colors.grey))]))
                  : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: grades.entries.map((entry) {
                  var types = entry.value as Map<String, dynamic>;
                  double s15 = (types['Miệng / 15 Phút'] ?? []).fold(0.0, (p, c) => p + (c as num).toDouble());
                  int c15 = (types['Miệng / 15 Phút'] ?? []).length;
                  double s1t = (types['1 Tiết / Giữa Kỳ'] ?? []).fold(0.0, (p, c) => p + (c as num).toDouble());
                  int c1t = (types['1 Tiết / Giữa Kỳ'] ?? []).length;
                  double sHk = (types['Học Kỳ'] ?? []).fold(0.0, (p, c) => p + (c as num).toDouble());
                  int cHk = (types['Học Kỳ'] ?? []).length;
                  int wTotal = c15 * 1 + c1t * 2 + cHk * 3;
                  double subAvg = wTotal > 0 ? (s15 * 1 + s1t * 2 + sHk * 3) / wTotal : 0.0;
                  Color badgeColor = subAvg >= 8.0 ? Colors.green : (subAvg >= 5.0 ? Colors.orange : Colors.redAccent);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: CircleAvatar(backgroundColor: badgeColor.withOpacity(0.1), child: Icon(Icons.menu_book, color: badgeColor)),
                        title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(wTotal > 0 ? subAvg.toStringAsFixed(1) : '-', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: badgeColor))),
                        children: types.entries.map((tEntry) {
                          List scores = tEntry.value as List;
                          return Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(tEntry.key, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                                Text(scores.isEmpty ? '-' : scores.join(", "), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }
    );

    final tabs = [studentListTab, timetableTab, gradesTab, AssignmentStudentScreen(student: widget.loggedInStudent)];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        title: Text('Hi, ${widget.loggedInStudent.name.split(' ').last} 👋', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          // NÚT XEM BẢNG TIN THÔNG BÁO MỚI THÊM
          IconButton(
            icon: const Icon(Icons.newspaper, color: Colors.white),
            tooltip: 'Bảng tin nhà trường',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsFeedScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.event_note, color: Colors.white),
            tooltip: 'Sự kiện',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(
                  appBar: AppBar(title: const Text('Sự kiện', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blueAccent, iconTheme: const IconThemeData(color: Colors.white)),
                  body: const EventsUserTab()
              )));
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_document, color: Colors.white),
            tooltip: 'Đơn xin nghỉ phép',
            onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveRequestStudentScreen(student: widget.loggedInStudent))); },
          ),
          InkWell(
            onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(student: widget.loggedInStudent))).then((value) { setState(() {}); }); },
            child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.white),
                )
            ),
          )
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group), label: 'Lớp học'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Lịch học'),
              BottomNavigationBarItem(icon: Icon(Icons.assessment_outlined), activeIcon: Icon(Icons.assessment), label: 'Bảng điểm'),
              // ĐÃ ĐỔI THÀNH TAB BÀI TẬP
              BottomNavigationBarItem(icon: Icon(Icons.drive_file_rename_outline), activeIcon: Icon(Icons.edit_document), label: 'Bài tập'),
            ],
          ),
        ),
      ),
    );
  }
}