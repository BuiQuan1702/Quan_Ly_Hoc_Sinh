// lib/models/student.dart

// ================= 1. DỮ LIỆU HỌC SINH & ĐIỂM SỐ =================
class Student {
  String id; String name; String className; String password;
  Map<String, Map<String, List<double>>> grades;

  Student({required this.id, required this.name, required this.className, required this.password, this.grades = const {}});
}

List<Student> mockStudents = [
  Student(id: 'HS001', name: 'Nguyễn Văn An', className: '10A1', password: '123', grades: {'Toán Học': {'Miệng / 15 Phút': [8.0, 9.0], '1 Tiết / Giữa Kỳ': [7.5], 'Học Kỳ': [8.0]}, 'Ngữ Văn': {'Miệng / 15 Phút': [7.0], '1 Tiết / Giữa Kỳ': [8.0], 'Học Kỳ': []}}),
  Student(id: 'HS002', name: 'Trần Thị Bình', className: '10A1', password: '123'),
  Student(id: 'HS003', name: 'Lê Hoàng Cường', className: '11B1', password: '123'),
];

// ================= 2. DỮ LIỆU GIÁO VIÊN (MỚI) =================
class Teacher {
  String id; String name; String phone; String password;
  Teacher({required this.id, required this.name, required this.phone, required this.password});
}

List<Teacher> mockTeachers = [
  Teacher(id: 'GV001', name: 'Phạm Văn Hà', phone: '0988123456', password: '123'),
  Teacher(id: 'GV002', name: 'Nguyễn Thị Hoa', phone: '0977654321', password: '123'),
  Teacher(id: 'GV003', name: 'Trần Đại Nghĩa', phone: '0912345678', password: '123'),
];

// ================= 3. DỮ LIỆU THỜI KHÓA BIỂU (ĐÃ PHÂN CÔNG GV) =================
class Lesson {
  String id;
  String date;
  String subject;
  String time;
  String className;
  String teacherName; // THÊM TRƯỜNG NÀY ĐỂ LƯU GIÁO VIÊN GIẢNG DẠY

  Lesson({required this.id, required this.date, required this.subject, required this.time, required this.className, required this.teacherName});
}

List<Lesson> mockTimetable = [
  Lesson(id: 'L01', date: '2026-06-22', subject: 'Toán Học', time: '07:00 - 08:30', className: '10A1', teacherName: 'Nguyễn Thị Hoa'),
  Lesson(id: 'L02', date: '2026-06-22', subject: 'Ngữ Văn', time: '08:40 - 10:10', className: '10A1', teacherName: 'Trần Đại Nghĩa'),
  Lesson(id: 'L04', date: '2026-06-27', subject: 'Công nghệ .Net', time: '06:45 - 09:25', className: '10A1', teacherName: 'Phạm Văn Hà'),
];

// ================= 4. DỮ LIỆU ĐIỂM DANH =================
Map<String, String> lessonAttendanceCodes = {};
Map<String, List<String>> lessonAttendedStudents = {};

// ================= 5. DỮ LIỆU ĐƠN XIN NGHỈ PHÉP =================
class LeaveRequest {
  String id; String studentId; String studentName; String className; String date; String reason; String status;
  LeaveRequest({required this.id, required this.studentId, required this.studentName, required this.className, required this.date, required this.reason, this.status = 'Chờ duyệt'});
}
List<LeaveRequest> mockLeaveRequests = [LeaveRequest(id: 'REQ01', studentId: 'HS001', studentName: 'Nguyễn Văn An', className: '10A1', date: '25/05/2026', reason: 'Em bị sốt cao')];

// ================= 6. DỮ LIỆU SỰ KIỆN & LỊCH THI =================
class SchoolEvent {
  String id; String title; String date; String description; String type;
  SchoolEvent({required this.id, required this.title, required this.date, required this.description, required this.type});
}
List<SchoolEvent> mockEvents = [
  SchoolEvent(id: 'EV01', title: 'Thi học kỳ 1 môn Toán', date: '20/12/2026', description: 'Học sinh có mặt trước 15 phút tại phòng đa năng.', type: 'Lịch thi'),
];