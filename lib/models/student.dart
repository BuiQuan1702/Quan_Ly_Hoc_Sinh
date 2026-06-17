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
// Thêm vào dưới cùng file lib/models/student.dart

// ================= 7. DỮ LIỆU BẢNG TIN THÔNG BÁO (MỚI) =================
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

// Danh sách bài đăng mẫu trên Bảng tin
List<NotificationPost> mockNotifications = [
  NotificationPost(
    id: 'N01',
    title: 'Thông báo đóng học phí học kỳ phụ 2026',
    content: 'Nhà trường thông báo thời hạn hoàn thành học phí học kỳ phụ từ ngày 20/06 đến hết ngày 30/06/2026. Sinh viên nộp qua cổng thanh toán trực tuyến hoặc chuyển khoản ngân hàng.',
    date: '15/06/2026',
    category: 'Học phí',
  ),
  NotificationPost(
    id: 'N02',
    title: 'Lịch thi tốt nghiệp và khảo sát chất lượng đầu ra',
    content: 'Kỳ thi khảo sát tiếng Anh và Tin học đầu ra dành cho sinh viên năm cuối sẽ diễn ra vào hai ngày thứ 7 và Chủ Nhật tuần sau. Danh sách phòng thi cụ thể đã được cập nhật tại văn phòng khoa.',
    date: '14/06/2026',
    category: 'Lịch thi',
  ),
  NotificationPost(
    id: 'N03',
    title: 'Phát động cuộc thi Sáng tạo Robot 2026',
    content: 'Chào mừng ngày thành lập trường, Đoàn thanh niên phát động cuộc thi Robocon cấp trường với giải thưởng lên đến 20 triệu đồng. Hạn cuối đăng ký đội thi là ngày 05/07/2026.',
    date: '12/06/2026',
    category: 'Sự kiện',
  ),
];
// ================= 8. DỮ LIỆU BÀI TẬP VỀ NHÀ (MỚI) =================
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

// Dữ liệu mẫu ban đầu
List<Assignment> mockAssignments = [
  Assignment(
      id: 'A01', title: 'Viết bài luận Tiếng Anh (Chủ đề Môi trường)',
      description: 'Các em viết một bài luận dài khoảng 250 từ. Có thể làm ra file Word rồi dán link Google Drive vào đây nhé.',
      className: '10A1', subject: 'Tiếng Anh', deadline: '2026-06-20 23:59', teacherName: 'Nguyễn Văn A'
  ),
];

List<Submission> mockSubmissions = [];