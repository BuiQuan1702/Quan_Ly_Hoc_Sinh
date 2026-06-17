// lib/screens/assignment_student_screen.dart
import 'package:flutter/material.dart';
import '../models/student.dart';

class AssignmentStudentScreen extends StatefulWidget {
  final Student student;
  const AssignmentStudentScreen({super.key, required this.student});

  @override
  State<AssignmentStudentScreen> createState() => _AssignmentStudentScreenState();
}

class _AssignmentStudentScreenState extends State<AssignmentStudentScreen> {

  void _showSubmitDialog(Assignment assignment, Submission? existingSubmission) {
    TextEditingController contentController = TextEditingController(text: existingSubmission?.content ?? '');
    bool isGraded = existingSubmission?.grade != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isGraded ? 'Kết quả bài làm' : 'Nộp bài tập', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(assignment.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 5),
              Text(assignment.description, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              const Divider(height: 20),

              if (isGraded) ...[
                Container(
                  padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      Text('Điểm số: ${existingSubmission!.grade}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 5),
                      Text('Nhận xét: ${existingSubmission.feedback ?? "Không có"}', style: TextStyle(color: Colors.green.shade700, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],

              const Text('Nội dung trả lời / Link bài làm:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                  controller: contentController, maxLines: 5,
                  readOnly: isGraded, // Đã chấm thì không được sửa nữa
                  decoration: InputDecoration(
                    hintText: 'Nhập câu trả lời hoặc dán link Google Drive, Docs...',
                    filled: true, fillColor: isGraded ? Colors.grey.shade100 : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  )
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng', style: TextStyle(color: Colors.grey))),
          if (!isGraded)
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  if (contentController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập nội dung!'), backgroundColor: Colors.redAccent));
                    return;
                  }
                  setState(() {
                    if (existingSubmission != null) {
                      existingSubmission.content = contentController.text;
                      existingSubmission.submittedAt = DateTime.now().toString();
                    } else {
                      mockSubmissions.add(Submission(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          assignmentId: assignment.id, studentId: widget.student.id, studentName: widget.student.name,
                          content: contentController.text, submittedAt: DateTime.now().toString()
                      ));
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nộp bài thành công!'), backgroundColor: Colors.green));
                },
                child: const Text('Gửi bài', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lọc bài tập của lớp học sinh này
    final myAssignments = mockAssignments.where((a) => a.className == widget.student.className).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: myAssignments.isEmpty
          ? const Center(child: Text('Chưa có bài tập nào được giao!', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myAssignments.length,
        itemBuilder: (context, index) {
          final assignment = myAssignments[index];
          // Kiểm tra xem đã nộp chưa
          final submissionIndex = mockSubmissions.indexWhere((s) => s.assignmentId == assignment.id && s.studentId == widget.student.id);
          final submission = submissionIndex != -1 ? mockSubmissions[submissionIndex] : null;

          String statusText = 'Chưa nộp'; Color statusColor = Colors.redAccent; IconData statusIcon = Icons.pending_actions;
          if (submission != null) {
            if (submission.grade != null) { statusText = 'Đã chấm (${submission.grade})'; statusColor = Colors.green; statusIcon = Icons.verified; }
            else { statusText = 'Đã nộp (Chờ chấm)'; statusColor = Colors.orange; statusIcon = Icons.hourglass_bottom; }
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 15), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: InkWell(
              onTap: () => _showSubmitDialog(assignment, submission),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(statusIcon, size: 14, color: statusColor), const SizedBox(width: 4), Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12))])),
                        Text('Hạn nộp: ${assignment.deadline}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(assignment.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Text('Môn: ${assignment.subject}  •  GV: ${assignment.teacherName}', style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade600)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}