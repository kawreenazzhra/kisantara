import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;
  final String category;
  final String readTime;
  final String part1;
  final String quote;
  final String quoteAuthor;
  final String part2;
  final String authorId;
  final String authorName;
  final DateTime timestamp;
  // Status: 'approved' | 'pending' | 'rejected'
  // Admin stories are immediately approved; user stories start as 'pending'
  final String status;

  const StoryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.category,
    required this.readTime,
    required this.part1,
    required this.quote,
    required this.quoteAuthor,
    required this.part2,
    required this.authorId,
    required this.authorName,
    required this.timestamp,
    this.status = 'approved',
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isAdminStory => authorId == 'admin';

  // Getter for Category Color matching the UI design
  Color get categoryColor {
    switch (category.toUpperCase()) {
      case 'LEGENDA':
        return const Color(0xFFBFD9FE); // Light blue
      case 'MITOS':
        return const Color(0xFFDDD6FE); // Light purple
      case 'FABEL':
        return const Color(0xFFC6F6D5); // Light green
      case 'FANTASI':
        return const Color(0xFFFFD1E6); // Light pink/magenta
      default:
        return const Color(0xFFFED023); // Default gold
    }
  }

  // Getter for Category Text Color matching the UI design
  Color get categoryTextColor {
    switch (category.toUpperCase()) {
      case 'LEGENDA':
        return const Color(0xFF1D5AA8);
      case 'MITOS':
        return const Color(0xFF5B21B6);
      case 'FABEL':
        return const Color(0xFF065F46);
      case 'FANTASI':
        return const Color(0xFF9C0E56); // Deep magenta
      default:
        return const Color(0xFF594700);
    }
  }

  // Convert from Firestore DocumentSnapshot to StoryModel
  factory StoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StoryModel(
      id: doc.id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      imagePath: data['imagePath'] ?? '',
      category: data['category'] ?? 'LEGENDA',
      readTime: data['readTime'] ?? '5 min baca',
      part1: data['part1'] ?? '',
      quote: data['quote'] ?? '',
      quoteAuthor: data['quoteAuthor'] ?? '',
      part2: data['part2'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonim',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'approved',
    );
  }

  // Convert from Map to StoryModel
  factory StoryModel.fromMap(Map<String, dynamic> data, String docId) {
    return StoryModel(
      id: docId,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      imagePath: data['imagePath'] ?? '',
      category: data['category'] ?? 'LEGENDA',
      readTime: data['readTime'] ?? '5 min baca',
      part1: data['part1'] ?? '',
      quote: data['quote'] ?? '',
      quoteAuthor: data['quoteAuthor'] ?? '',
      part2: data['part2'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonim',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'approved',
    );
  }

  // Convert StoryModel to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'imagePath': imagePath,
      'category': category,
      'readTime': readTime,
      'part1': part1,
      'quote': quote,
      'quoteAuthor': quoteAuthor,
      'part2': part2,
      'authorId': authorId,
      'authorName': authorName,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }
}
