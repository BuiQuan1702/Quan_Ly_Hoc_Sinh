// lib/models/student.dart

// ================= 1. DỮ LIỆU HỌC SINH & ĐIỂM SỐ =================
class Student {
  String id;
  String name;
  String className;
  String password;

  // Cấu trúc mới: Môn học -> { Loại điểm -> [Danh sách điểm] }
  // VD: {'Toán': {'15 Phút': [8.0, 9.0], '1 Tiết': [7.5], 'Học Kỳ': [9.0]}}
  Map<String, Map<String, List<double>>> grades;

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.password,
    this.grades = const {},
  });
}

List<Student> mockStudents = [
  Student(
      id: 'HS001', name: 'Nguyễn Văn An', className: '10A1', password: '123',
      grades: {
        'Toán Học': {
          'Miệng / 15 Phút': [8.0, 9.0],
          '1 Tiết / Giữa Kỳ': [7.5],
          'Học Kỳ': [8.0]
        },
        'Ngữ Văn': {
          'Miệng / 15 Phút': [7.0],
          '1 Tiết / Giữa Kỳ': [8.0],
          'Học Kỳ': []
        }
      }
  ),
  Student(id: 'HS002', name: 'Trần Thị Bình', className: '10A1', password: '123'),
  Student(id: 'HS003', name: 'Lê Hoàng Cường', className: '11B1', password: '123'),
];

// ================= 2. DỮ LIỆU THỜI KHÓA BIỂU =================
class Lesson {
  String id;
  String day;
  String subject;
  String time;
  String className;

  Lesson({
    required this.id, required this.day, required this.subject,
    required this.time, required this.className
  });
}

List<Lesson> mockTimetable = [
  Lesson(id: 'L01', day: 'Thứ 2', subject: 'Toán Học', time: '07:00 - 08:30', className: '10A1'),
  Lesson(id: 'L02', day: 'Thứ 2', subject: 'Ngữ Văn', time: '08:40 - 10:10', className: '10A1'),
  Lesson(id: 'L03', day: 'Thứ 3', subject: 'Tiếng Anh', time: '07:00 - 08:30', className: '10A1'),
  Lesson(id: 'L04', day: 'Thứ 4', subject: 'Vật Lý', time: '08:40 - 10:10', className: '11B1'),
];

// ================= 3. DỮ LIỆU ĐIỂM DANH =================
Map<String, String> lessonAttendanceCodes = {};
Map<String, List<String>> lessonAttendedStudents = {};

// ================= 4. DỮ LIỆU ĐƠN XIN NGHỈ PHÉP =================
class LeaveRequest {
  String id;
  String studentId;
  String studentName;
  String className;
  String date;
  String reason;
  String status;

  LeaveRequest({
    required this.id, required this.studentId, required this.studentName,
    required this.className, required this.date, required this.reason,
    this.status = 'Chờ duyệt'
  });
}

List<LeaveRequest> mockLeaveRequests = [
  LeaveRequest(id: 'REQ01', studentId: 'HS001', studentName: 'Nguyễn Văn An', className: '10A1', date: '25/05/2026', reason: 'Em bị sốt cao'),
];