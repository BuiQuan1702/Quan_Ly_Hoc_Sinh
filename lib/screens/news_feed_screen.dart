// lib/screens/news_feed_screen.dart
import 'package:flutter/material.dart';
import '../models/student.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sắp xếp thông báo mới nhất lên đầu
    final posts = mockNotifications.reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Bảng Tin Nhà Trường', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: posts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.newspaper_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            const Text('Chưa có thông báo nào mới', style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];

          // Tự động đổi màu Tag theo danh mục bài viết
          Color categoryColor = Colors.blue;
          if (post.category == 'Học phí') categoryColor = Colors.redAccent;
          if (post.category == 'Lịch thi') categoryColor = Colors.orange;
          if (post.category == 'Sự kiện') categoryColor = Colors.purple;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hàng hiển thị ngày và danh mục bài viết
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          post.category,
                          style: TextStyle(color: categoryColor, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      Text(
                        post.date,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Tiêu đề thông báo
                  Text(
                    post.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87, height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  // Nội dung tóm tắt thông báo
                  Text(
                    post.content,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}