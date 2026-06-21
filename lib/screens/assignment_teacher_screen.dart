// lib/screens/assignment_teacher_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class AssignmentTeacherScreen extends StatefulWidget {
  final Teacher teacher;
  const AssignmentTeacherScreen({super.key, required this.teacher});

  @override
  State<AssignmentTeacherScreen> createState() => _AssignmentTeacherScreenState();
}

class _AssignmentTeacherScreenState extends State<AssignmentTeacherScreen> {
  // Hàm tạo bài tập mới
  void _showCreateAssignmentDialog() async {
    // Lấy danh sách các lớp giáo viên này dạy từ Firestore (timetable)
    final timetableSnapshot = await FirebaseFirestore.instance
        .collection('timetable')
        .where('teacherName', isEqualTo: widget.teacher.name)
        .get();

    final myClasses = timetableSnapshot.docs.map((doc) => doc['className'] as String).toSet().toList();
    final mySubjects = timetableSnapshot.docs.map((doc) => doc['subject'] as String).toSet().toList();

    if (myClasses.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bạn chưa được phân công dạy lớp nào!'), backgroundColor: Colors.red));
      }
      return;
    }

    String selectedClass = myClasses.first;
    String selectedSubject = mySubjects.isNotEmpty ? mySubjects.first : 'Môn chung';
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();

    DateTime chosenDate = DateTime.now().add(const Duration(days: 3)); // Mặc định hạn nộp là 3 ngày sau
    TextEditingController deadlineController = TextEditingController(text: "${chosenDate.year}-${chosenDate.month.toString().padLeft(2, '0')}-${chosenDate.day.toString().padLeft(2, '0')} 23:59");

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Giao bài tập mới', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: DropdownButtonFormField<String>(value: selectedClass, decoration: const InputDecoration(labelText: 'Lớp', border: OutlineInputBorder()), items: myClasses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) => setDialogState(() => selectedClass = val!))),
                    const SizedBox(width: 10),
                    Expanded(child: DropdownButtonFormField<String>(value: selectedSubject, decoration: const InputDecoration(labelText: 'Môn', border: OutlineInputBorder()), items: mySubjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (val) => setDialogState(() => selectedSubject = val!))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tiêu đề bài tập', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Yêu cầu chi tiết', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(
                  controller: deadlineController, readOnly: true,
                  decoration: const InputDecoration(labelText: 'Hạn nộp (Deadline)', suffixIcon: Icon(Icons.timer), border: OutlineInputBorder()),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(context: context, initialDate: chosenDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 23, minute: 59));
                      if (pickedTime != null) {
                        setDialogState(() {
                          deadlineController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')} ${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('assignments').add({
                    'title': titleController.text,
                    'description': descController.text,
                    'className': selectedClass,
                    'subject': selectedSubject,
                    'deadline': deadlineController.text,
                    'teacherName': widget.teacher.name,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã giao bài tập thành công!'), backgroundColor: Colors.green));
                  }
                },
                child: const Text('Giao bài', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            )
          ],
        ),
      ),
    );
  }

  // Hàm chấm điểm bài làm
  void _showGradingDialog(DocumentSnapshot submissionDoc) {
    Map<String, dynamic> submission = submissionDoc.data() as Map<String, dynamic>;
    TextEditingController gradeController = TextEditingController(text: submission['grade']?.toString() ?? '');
    TextEditingController feedbackController = TextEditingController(text: submission['feedback'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Chấm bài: ${submission['studentName']}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nội dung / Link bài làm:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 5),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: SelectableText(submission['content'] ?? '', style: const TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline)),
              ),
              const SizedBox(height: 15),
              TextField(controller: gradeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Điểm số (0-10)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.score, color: Colors.orange))),
              const SizedBox(height: 10),
              TextField(controller: feedbackController, maxLines: 2, decoration: const InputDecoration(labelText: 'Lời phê của Giáo viên', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                double? grade = double.tryParse(gradeController.text);
                if (grade != null && grade >= 0 && grade <= 10) {
                  await submissionDoc.reference.update({
                    'grade': grade,
                    'feedback': feedbackController.text,
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã chấm điểm thành công!'), backgroundColor: Colors.green));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Điểm không hợp lệ!'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Lưu điểm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          )
        ],
      ),
    );
  }

  // Danh sách học sinh nộp bài
  void _showSubmissionsBottomSheet(DocumentSnapshot assignmentDoc) {
    String assignmentId = assignmentDoc.id;
    String className = assignmentDoc['className'];

    showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (context) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('submissions').where('assignmentId', isEqualTo: assignmentId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final submissions = snapshot.data?.docs ?? [];

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('students').where('className', isEqualTo: className).get(),
                builder: (context, studentSnapshot) {
                  int classSize = studentSnapshot.data?.docs.length ?? 0;

                  return Container(
                    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    child: FractionallySizedBox(
                      heightFactor: 0.85,
                      child: Column(
                        children: [
                          Container(margin: const EdgeInsets.only(top: 10), width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(assignmentDoc['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo), textAlign: TextAlign.center),
                                const SizedBox(height: 5),
                                Text('Lớp: $className | Đã nộp: ${submissions.length}/$classSize', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: submissions.isEmpty
                                ? const Center(child: Text('Chưa có học sinh nào nộp bài', style: TextStyle(color: Colors.grey)))
                                : ListView.builder(
                              itemCount: submissions.length,
                              itemBuilder: (context, index) {
                                final subDoc = submissions[index];
                                final subData = subDoc.data() as Map<String, dynamic>;
                                bool isGraded = subData['grade'] != null;
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  child: ListTile(
                                    leading: CircleAvatar(backgroundColor: isGraded ? Colors.green.shade100 : Colors.orange.shade100, child: Icon(isGraded ? Icons.check_circle : Icons.pending, color: isGraded ? Colors.green : Colors.orange)),
                                    title: Text(subData['studentName'] ?? 'Học sinh', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('Nộp lúc: ${subData['submittedAt']?.toString().substring(0, 16) ?? ""}', style: const TextStyle(fontSize: 12)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: isGraded ? Colors.green : Colors.orange, borderRadius: BorderRadius.circular(15)),
                                      child: Text(isGraded ? '${subData['grade']} đ' : 'Chấm', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    onTap: () => _showGradingDialog(subDoc),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('assignments')
            .where('teacherName', isEqualTo: widget.teacher.name)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final assignments = snapshot.data?.docs ?? [];

          if (assignments.isEmpty) {
            return const Center(child: Text('Bạn chưa giao bài tập nào.', style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignmentDoc = assignments[index];
              final assignment = assignmentDoc.data() as Map<String, dynamic>;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('submissions').where('assignmentId', isEqualTo: assignmentDoc.id).snapshots(),
                builder: (context, subSnapshot) {
                  int subCount = subSnapshot.data?.docs.length ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: InkWell(
                      onTap: () => _showSubmissionsBottomSheet(assignmentDoc),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                    child: Text(
                                      'Lớp ${assignment['className']} - ${assignment['subject']}',
                                      style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('Đã nộp: $subCount', style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              assignment['title'] ?? '',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87),
                              softWrap: true,
                            ),
                            const SizedBox(height: 6),
                            Text('Hạn nộp: ${assignment['deadline'] ?? ''}', style: TextStyle(fontSize: 13, color: Colors.redAccent.shade700, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAssignmentDialog,
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Giao bài', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}