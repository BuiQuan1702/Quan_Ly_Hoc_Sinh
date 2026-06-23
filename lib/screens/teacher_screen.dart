import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm Firebase
import '../models/student.dart';
import 'teacher_profile_screen.dart';
import 'leave_manage_teacher_screen.dart';
import 'news_feed_screen.dart';
import 'assignment_teacher_screen.dart';
import 'events_admin_tab.dart'; // Thêm import này

class TeacherScreen extends StatefulWidget {
  final Teacher loggedInTeacher;

  const TeacherScreen({super.key, required this.loggedInTeacher});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  int _currentIndex = 0;
  final List<String> gradeTypes = ['Chuyên cần (10%)', 'Giữa Kỳ', 'Cuối Kỳ'];
  final List<String> scoringMethods = ['Loại 1 (10-40-50)', 'Loại 2 (10-30-60)'];

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  String _getWeekdayString(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      switch (date.weekday) {
        case 1: return 'Thứ 2';
        case 2: return 'Thứ 3';
        case 3: return 'Thứ 4';
        case 4: return 'Thứ 5';
        case 5: return 'Thứ 6';
        case 6: return 'Thứ 7';
        case 7: return 'Chủ Nhật';
        default: return '';
      }
    } catch (e) {
      return '';
    }
  }

  // Stream lấy lịch dạy của giáo viên
  Stream<List<Lesson>> _getMyLessons() {
    return FirebaseFirestore.instance
        .collection('timetable')
        .where('teacherName', isEqualTo: widget.loggedInTeacher.name)
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

  // ================= BẢNG ĐIỀU KHIỂN ĐIỂM DANH (FIREBASE) =================
  void _showAttendanceBottomSheet(BuildContext context, Lesson lesson) {
    showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('timetable').doc(lesson.id).snapshots(),
            builder: (context, lessonSnapshot) {
              if (!lessonSnapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              var lessonData = lessonSnapshot.data!.data() as Map<String, dynamic>? ?? {};
              String? currentCode = lessonData['attendanceCode'];
              List<dynamic> attendedList = lessonData['attendedStudents'] ?? [];

              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('students').snapshots(),
                      builder: (context, studentSnapshot) {
                        if (!studentSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                        
                        // Lọc học sinh thuộc lớp này (Hỗ trợ cả cũ và mới)
                        final studentsInClass = studentSnapshot.data!.docs.where((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          var classes = data['classNames'] as List? ?? [];
                          return classes.contains(lesson.className) || data['className'] == lesson.className;
                        }).toList();

                        return Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24))
                          ),
                          child: FractionallySizedBox(
                            heightFactor: 0.85,
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 10), width: 50, height: 5,
                                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        Text('Điểm danh: Lớp ${lesson.className}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
                                        Text('${lesson.subject} | ${lesson.time}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                                      ],
                                    )
                                ),
                                Container(
                                  width: double.infinity, margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(20.0),
                                  decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blueAccent.withOpacity(0.2))),
                                  child: Column(
                                    children: [
                                      if (currentCode != null)
                                        Text(currentCode, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.blueAccent, letterSpacing: 8))
                                      else
                                        const Text('Chưa mở điểm danh', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 15),
                                      ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blueAccent,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                                          ),
                                          onPressed: () async {
                                            String newCode = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
                                            await FirebaseFirestore.instance.collection('timetable').doc(lesson.id).update({
                                              'attendanceCode': newCode,
                                              'attendedStudents': []
                                            });
                                          },
                                          icon: const Icon(Icons.qr_code, color: Colors.white),
                                          label: const Text('Mở Điểm danh & Tạo mã', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Container(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), width: double.infinity, color: Colors.grey.shade50, child: Text('DANH SÁCH HỌC SINH (${attendedList.length}/${studentsInClass.length})', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 1))),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: studentsInClass.length,
                                    itemBuilder: (context, index) {
                                      final studentDoc = studentsInClass[index];
                                      final studentData = studentDoc.data() as Map<String, dynamic>;
                                      final studentId = studentData['id'];
                                      final isAttended = attendedList.contains(studentId);
                                      
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                        decoration: BoxDecoration(color: isAttended ? Colors.green.shade50 : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isAttended ? Colors.green.shade200 : Colors.grey.shade200)),
                                        child: CheckboxListTile(
                                            activeColor: Colors.green,
                                            value: isAttended,
                                            title: Text(studentData['name'] ?? '', style: TextStyle(fontWeight: isAttended ? FontWeight.bold : FontWeight.normal)),
                                            subtitle: Text('Mã HS: $studentId'),
                                            secondary: CircleAvatar(backgroundColor: isAttended ? Colors.green : Colors.grey.shade300, child: const Icon(Icons.person, color: Colors.white)),
                                            onChanged: (val) async {
                                              if (val == true) {
                                                await FirebaseFirestore.instance.collection('timetable').doc(lesson.id).update({
                                                  'attendedStudents': FieldValue.arrayUnion([studentId])
                                                });
                                              } else {
                                                await FirebaseFirestore.instance.collection('timetable').doc(lesson.id).update({
                                                  'attendedStudents': FieldValue.arrayRemove([studentId])
                                                });
                                              }
                                            }
                                        ),
                                      );
                                    },
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
          );
        }
    );
  }

  // ================= BẢNG ĐIỀU KHIỂN CHẤM & SỬA ĐIỂM (FIREBASE) =================
  void _showEditScoreDialog(BuildContext context, String docId, String name, Map<String, dynamic> allGrades, String subject, String type, int scoreIndex, double currentValue) {
    TextEditingController editController = TextEditingController(text: currentValue.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sửa điểm môn: $subject', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Học sinh: $name', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Loại điểm: $type', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: editController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Điểm số (0-10)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Map<String, dynamic> newGrades = Map.from(allGrades);
              List<dynamic> scores = List.from(newGrades[subject][type]);
              scores.removeAt(scoreIndex);
              newGrades[subject][type] = scores;
              await FirebaseFirestore.instance.collection('students').doc(docId).update({'grades': newGrades});
              Navigator.pop(context);
            },
            child: const Text('Xóa điểm', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              double? sc = double.tryParse(editController.text);
              if (sc != null && sc >= 0 && sc <= 10) {
                Map<String, dynamic> newGrades = Map.from(allGrades);
                List<dynamic> scores = List.from(newGrades[subject][type]);
                scores[scoreIndex] = sc;
                newGrades[subject][type] = scores;
                await FirebaseFirestore.instance.collection('students').doc(docId).update({'grades': newGrades});
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Điểm không hợp lệ!')));
              }
            },
            child: const Text('Cập nhật', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showGradesBottomSheet(BuildContext context, String studentDocId, String studentName, List<String> subjectsTaught) {
    if (subjectsTaught.isEmpty) subjectsTaught = ['Môn chung'];
    String selectedSubject = subjectsTaught.first;
    String selectedType = gradeTypes.first;
    TextEditingController scoreController = TextEditingController();

    showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('students').doc(studentDocId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    
                    var studentData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                    Map<String, dynamic> currentGrades = studentData['grades'] ?? {};
                    String selectedMethod = currentGrades[selectedSubject]?['scoringMethod'] ?? scoringMethods.first;

                    return Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                        child: FractionallySizedBox(
                          heightFactor: 0.85,
                          child: Column(
                            children: [
                              Container(margin: const EdgeInsets.only(top: 10), width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                              Padding(padding: const EdgeInsets.all(20.0), child: Text('Chấm & Sửa điểm: $studentName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.orange))),
                              Container(
                                padding: const EdgeInsets.all(20.0), margin: const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.shade200)),
                                child: Column(
                                  children: [
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: selectedSubject,
                                      decoration: const InputDecoration(labelText: 'Chọn môn học', border: OutlineInputBorder()),
                                      items: subjectsTaught.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                      onChanged: (val) {
                                        setModalState(() {
                                          selectedSubject = val!;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            value: selectedMethod,
                                            decoration: const InputDecoration(labelText: 'Cách tính điểm', border: OutlineInputBorder()),
                                            items: scoringMethods.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12)))).toList(),
                                            onChanged: (val) async {
                                              Map<String, dynamic> newGrades = Map.from(currentGrades);
                                              if (newGrades[selectedSubject] == null) {
                                                newGrades[selectedSubject] = {
                                                  'scoringMethod': val,
                                                  'Chuyên cần (10%)': [],
                                                  'Giữa Kỳ': [],
                                                  'Cuối Kỳ': []
                                                };
                                              } else {
                                                newGrades[selectedSubject]['scoringMethod'] = val;
                                              }
                                              await FirebaseFirestore.instance.collection('students').doc(studentDocId).update({'grades': newGrades});
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            value: selectedType,
                                            decoration: const InputDecoration(labelText: 'Loại điểm', border: OutlineInputBorder()),
                                            items: gradeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                                            onChanged: (val) => setModalState(() => selectedType = val!),
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
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                              filled: true,
                                              fillColor: Colors.white,
                                              labelText: 'Nhập điểm số (0-10)',
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                            ),
                                            onPressed: () async {
                                              double? sc = double.tryParse(scoreController.text);
                                              if (sc != null && sc >= 0 && sc <= 10) {
                                                Map<String, dynamic> newGrades = Map.from(currentGrades);
                                                if (newGrades[selectedSubject] == null) {
                                                  newGrades[selectedSubject] = {
                                                    'scoringMethod': selectedMethod,
                                                    'Chuyên cần (10%)': [],
                                                    'Giữa Kỳ': [],
                                                    'Cuối Kỳ': []
                                                  };
                                                }
                                                
                                                List<dynamic> currentScores = List.from(newGrades[selectedSubject][selectedType] ?? []);
                                                currentScores.add(sc);
                                                newGrades[selectedSubject][selectedType] = currentScores;

                                                await FirebaseFirestore.instance.collection('students').doc(studentDocId).update({
                                                  'grades': newGrades
                                                });
                                                scoreController.clear();
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu điểm thành công!'), backgroundColor: Colors.green));
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Điểm không hợp lệ!'), backgroundColor: Colors.redAccent));
                                              }
                                            },
                                            child: const Text('Lưu điểm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.centerLeft,
                                child: const Text('Bấm vào điểm số để Sửa hoặc Xóa', style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontStyle: FontStyle.italic)),
                              ),
                              const SizedBox(height: 5),
                              Expanded(
                                child: (currentGrades.entries.where((e) => subjectsTaught.contains(e.key)).isEmpty) ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.assignment_outlined, size: 50, color: Colors.grey.shade300), const SizedBox(height: 10), const Text('Chưa có điểm số nào cho các môn bạn dạy', style: TextStyle(color: Colors.grey))])) : ListView(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  children: currentGrades.entries.where((e) => subjectsTaught.contains(e.key)).map((e) {
                                    Map<String, dynamic> subjectData = e.value as Map<String, dynamic>;
                                    String method = subjectData['scoringMethod'] ?? 'Chưa chọn';
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                                      child: Theme(
                                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                        child: ExpansionTile(
                                            leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.book, color: Colors.white, size: 18)),
                                            title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            subtitle: Text('Cách tính: $method', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                                            children: subjectData.entries.where((entry) => entry.key != 'scoringMethod').map((te) {
                                              List scores = te.value as List;
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(te.key, style: TextStyle(color: Colors.grey.shade600)),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Wrap(
                                                        alignment: WrapAlignment.end,
                                                        spacing: 8,
                                                        runSpacing: 4,
                                                        children: scores.asMap().entries.map((scoreEntry) {
                                                          int scoreIdx = scoreEntry.key;
                                                          double scoreVal = (scoreEntry.value as num).toDouble();
                                                          return InkWell(
                                                            onTap: () => _showEditScoreDialog(context, studentDocId, studentName, currentGrades, e.key, te.key, scoreIdx, scoreVal),
                                                            child: Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.withOpacity(0.3))),
                                                              child: Text(scoreVal.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            }).toList()
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                );
              }
          );
        }
    );
  }

  // ================= LƯỚI LỊCH DẠY CỦA GIÁO VIÊN =================
  Widget _buildTimetableGrid(List<DateTime> weekDates, List<Lesson> myLessons) {
    const double hourHeight = 65.0;
    const double dayWidth = 110.0;
    const double timeColumnWidth = 55.0;
    const double headerHeight = 55.0;
    const int startHour = 6; const int endHour = 18; const int hourCount = endHour - startHour + 1;
    final List<String> days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            width: timeColumnWidth + days.length * dayWidth, height: headerHeight + hourCount * hourHeight, color: const Color(0xFFF9FAFC),
            child: Stack(
              children: [
                for (int i = 0; i <= hourCount; i++) Positioned(top: headerHeight + i * hourHeight, left: 0, right: 0, child: Container(height: 1, color: Colors.grey.shade200)),
                for (int i = 0; i <= days.length; i++) Positioned(top: 0, bottom: 0, left: timeColumnWidth + i * dayWidth, child: Container(width: 1, color: Colors.grey.shade200)),
                for (int i = 0; i < hourCount; i++) Positioned(top: headerHeight + i * hourHeight, left: 0, width: timeColumnWidth, height: hourHeight, child: Center(child: Text('${startHour + i}:00', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)))),
                for (int i = 0; i < days.length; i++)
                  Positioned(
                    top: 0, left: timeColumnWidth + i * dayWidth, width: dayWidth, height: headerHeight,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.indigo.shade50, border: Border(bottom: BorderSide(color: Colors.indigo.shade100, width: 2))),
                      child: Center(child: Text('${days[i]}\n(${weekDates[i].day.toString().padLeft(2, '0')}/${weekDates[i].month.toString().padLeft(2, '0')})', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade800, fontSize: 12))),
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

      return Positioned(
        top: top, left: left, width: dWidth, height: height,
        child: InkWell(
          onTap: () => _showAttendanceBottomSheet(context, lesson),
          child: Container(
            margin: const EdgeInsets.all(3), padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.indigo.shade50, border: Border(left: BorderSide(color: Colors.indigo.shade400, width: 4)), borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(2, 2))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${lesson.subject}\nLớp ${lesson.className}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.indigo.shade700, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3), Text(lesson.time, style: TextStyle(fontSize: 10, color: Colors.grey.shade700)), const Spacer(),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [Icon(Icons.qr_code_scanner, size: 14, color: Colors.indigo.shade400)]),
              ],
            ),
          ),
        ),
      );
    } catch (e) { return const SizedBox.shrink(); }
  }


  @override
  Widget build(BuildContext context) {
    // ================= TAB 1: DANH SÁCH LỚP (FIREBASE) =================
    Widget myClassesTab = StreamBuilder<List<Lesson>>(
      stream: _getMyLessons(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final myLessons = snapshot.data ?? [];
        final myClasses = myLessons.map((l) => l.className).toSet().toList()..sort();
        final mySubjects = myLessons.map((l) => l.subject).toSet().toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: myClasses.isEmpty ? const Center(child: Text('Bạn chưa được phân công dạy lớp nào.', style: TextStyle(color: Colors.grey))) : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myClasses.length,
            itemBuilder: (context, classIndex) {
              String currentClass = myClasses[classIndex];
              List<Lesson> classLessons = myLessons.where((l) => l.className == currentClass).toList();
              final classSubjects = classLessons.map((l) => l.subject).toSet().toList();
              String scheduleInfo = classLessons.map((l) => '• ${l.subject} (${_getWeekdayString(l.date)}, ${l.date} | ${l.time})').join('\n');
              if (scheduleInfo.isEmpty) scheduleInfo = 'Chưa phân bổ lịch';

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('students').snapshots(),
                builder: (context, studentSnapshot) {
                  if (!studentSnapshot.hasData) return const SizedBox.shrink();
                  
                  // Lọc học sinh thuộc lớp này (Hỗ trợ cả cũ và mới)
                  final studentsInClassDocs = studentSnapshot.data!.docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    var classes = data['classNames'] as List? ?? [];
                    return classes.contains(currentClass) || data['className'] == currentClass;
                  }).toList();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))]),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        leading: CircleAvatar(backgroundColor: Colors.indigo.shade50, child: Icon(Icons.class_, color: Colors.indigo.shade400)),
                        title: Text('Lớp: $currentClass', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo.shade800, fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(10)), child: Text('Sĩ số: ${studentsInClassDocs.length} học sinh', style: TextStyle(color: Colors.blueGrey.shade700, fontWeight: FontWeight.bold, fontSize: 12))),
                            const SizedBox(height: 10),
                            const Text('Lịch dạy của bạn:', style: TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(scheduleInfo, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5)),
                            const SizedBox(height: 10),
                          ],
                        ),
                        children: studentsInClassDocs.map((studentDoc) {
                          var studentData = studentDoc.data() as Map<String, dynamic>;
                          return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: CircleAvatar(backgroundColor: Colors.blueAccent.withOpacity(0.1), child: const Icon(Icons.person, color: Colors.blueAccent)),
                                title: Text(studentData['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Mã HS: ${studentData['id']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                trailing: IconButton(
                                    icon: const Icon(Icons.stars, color: Colors.orange, size: 32),
                                    tooltip: 'Chấm điểm',
                                    onPressed: () => _showGradesBottomSheet(context, studentDoc.id, studentData['name'] ?? '', classSubjects)
                                ),
                              )
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
              );
            },
          ),
        );
      }
    );

    // ================= TAB 2: LỊCH DẠY CỦA TÔI (FIREBASE) =================
    DateTime startOfWeek = _selectedDay!.subtract(Duration(days: _selectedDay!.weekday - 1));
    List<DateTime> weekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    Widget myScheduleTab = StreamBuilder<List<Lesson>>(
      stream: _getMyLessons(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final myLessons = snapshot.data ?? [];

        return Column(
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
                calendarStyle: CalendarStyle(selectedDecoration: BoxDecoration(color: Colors.indigo.shade400, shape: BoxShape.circle), todayDecoration: BoxDecoration(color: Colors.indigo.shade200, shape: BoxShape.circle)),
                headerStyle: HeaderStyle(formatButtonVisible: true, titleCentered: true, formatButtonDecoration: BoxDecoration(color: Colors.indigo.shade400, borderRadius: const BorderRadius.all(Radius.circular(12.0))), formatButtonTextStyle: const TextStyle(color: Colors.white)),
              ),
            ),
            Expanded(child: _buildTimetableGrid(weekDates, myLessons)),
          ],
        );
      }
    );

    final tabs = [myClassesTab, myScheduleTab, AssignmentTeacherScreen(teacher: widget.loggedInTeacher)];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.indigo, Colors.blueAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Không gian Giáo viên', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('GV: ${widget.loggedInTeacher.name}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        actions: [
          // NÚT XEM SỰ KIỆN (MỚI THÊM)
          IconButton(
            icon: const Icon(Icons.event_note, color: Colors.white),
            tooltip: 'Sự kiện & Lịch thi',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Sự kiện & Lịch thi')),
                body: EventsAdminTab(), // Bỏ const để tránh lỗi constructor
              )));
            },
          ),
          
          // NÚT XEM BẢNG TIN THÔNG BÁO
          IconButton(
            icon: const Icon(Icons.newspaper, color: Colors.white),
            tooltip: 'Bảng tin nhà trường',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsFeedScreen()));
            },
          ),

          // Nút duyệt đơn xin nghỉ cũ giữ nguyên
          IconButton(
            icon: const Icon(Icons.fact_check_outlined, color: Colors.white),
            tooltip: 'Duyệt đơn xin nghỉ',
            onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveManageTeacherScreen(teacher: widget.loggedInTeacher))); },
          ),
          InkWell(
            onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherProfileScreen(teacher: widget.loggedInTeacher))).then((value) { setState(() {}); }); },
            child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 8.0),
                child: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.2), child: const Icon(Icons.person, color: Colors.white))
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
              type: BottomNavigationBarType.fixed, backgroundColor: Colors.white,
              currentIndex: _currentIndex, selectedItemColor: Colors.indigo, unselectedItemColor: Colors.grey.shade400,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group), label: 'Lớp đang dạy'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Lịch dạy của tôi'),
                // TAB MỚI THÊM VÀO
                BottomNavigationBarItem(icon: Icon(Icons.drive_file_rename_outline), activeIcon: Icon(Icons.edit_document), label: 'Giao bài tập'),
              ]
          ),
        ),
      ),
    );
  }
}