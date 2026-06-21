// lib/models/student.dart

// ================= 1. DỮ LIỆU HỌC SINH & ĐIỂM SỐ =================
class Student {
  String id; String name; String className; String password;
  Map<String, Map<String, List<double>>> grades;

  Student({required this.id, required this.name, required this.className, required this.password, this.grades = const {}});
}

// ================= 2. DỮ LIỆU GIÁO VIÊN =================
class Teacher {
  String id; String name; String phone; String password;
  Teacher({required this.id, required this.name, required this.phone, required this.password});
}

// ================= 3. DỮ LIỆU THỜI KHÓA BIỂU =================
class Lesson {
  String id;
  String date;
  String subject;
  String time;
  String className;
  String teacherName;
  String? room;

  Lesson({
    required this.id,
    required this.date,
    required this.subject,
    required this.time,
    required this.className,
    required this.teacherName,
    this.room,
  });
}

// ================= 4. DỮ LIỆU ĐƠN XIN NGHỈ PHÉP =================
class LeaveRequest {
  String id; String studentId; String studentName; String className; String date; String reason; String status;
  LeaveRequest({required this.id, required this.studentId, required this.studentName, required this.className, required this.date, required this.reason, this.status = 'Chờ duyệt'});
}

// ================= 5. DỮ LIỆU SỰ KIỆN & LỊCH THI =================
class SchoolEvent {
  String id; String title; String date; String description; String type;
  SchoolEvent({required this.id, required this.title, required this.date, required this.description, required this.type});
}

// ================= 6. DỮ LIỆU BẢNG TIN THÔNG BÁO =================
class NotificationPost {
  String id;
  String title;
  String content;
  String date;
  String category; // 'Chung', 'Học phí', 'Lịch thi', 'Sự kiện'

  NotificationPost({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.category,
  });
}

// ================= 7. DỮ LIỆU BÀI TẬP VỀ NHÀ =================
class Assignment {
  String id;
  String title;
  String description;
  String className;
  String subject;
  String deadline;
  String teacherName;

  Assignment({
    required this.id, required this.title, required this.description,
    required this.className, required this.subject, required this.deadline, required this.teacherName
  });
}

class Submission {
  String id;
  String assignmentId;
  String studentId;
  String studentName;
  String content; // Nội dung văn bản hoặc Link bài làm
  String submittedAt;
  double? grade;  // Điểm số (có thể null nếu chưa chấm)
  String? feedback; // Lời phê

  Submission({
    required this.id, required this.assignmentId, required this.studentId, required this.studentName,
    required this.content, required this.submittedAt, this.grade, this.feedback
  });
}
