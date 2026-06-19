import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId; // User ID penerima notifikasi
  final String type; // 'approval', 'new_story_admin', 'new_story_user'
  final String title;
  final String message;
  final String? storyId; // ID cerita yang diefer
  final String? storyTitle;
  final String? authorName;
  final String? authorId;
  final String? category;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.storyId,
    this.storyTitle,
    this.authorName,
    this.authorId,
    this.category,
    required this.timestamp,
    this.isRead = false,
  });

  /// Convert Firestore document to NotificationModel
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'notification',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      storyId: data['storyId'],
      storyTitle: data['storyTitle'],
      authorName: data['authorName'],
      authorId: data['authorId'],
      category: data['category'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  /// Convert NotificationModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'storyId': storyId,
      'storyTitle': storyTitle,
      'authorName': authorName,
      'authorId': authorId,
      'category': category,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}
