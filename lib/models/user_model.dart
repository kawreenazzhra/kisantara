import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String penName;
  final String role; // 'admin' or 'user'
  final String bio;
  final String language;
  final List<String> savedStories;
  final List<String> recentlyRead;

  const UserModel({
    required this.uid,
    required this.email,
    required this.penName,
    required this.role,
    required this.bio,
    required this.language,
    required this.savedStories,
    required this.recentlyRead,
  });

  // Convert from Firestore DocumentSnapshot to UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      penName: data['penName'] ?? '',
      role: data['role'] ?? 'user',
      bio: data['bio'] ?? '',
      language: data['language'] ?? 'Bahasa Indonesia',
      savedStories: List<String>.from(data['savedStories'] ?? []),
      recentlyRead: List<String>.from(data['recentlyRead'] ?? []),
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'penName': penName,
      'role': role,
      'bio': bio,
      'language': language,
      'savedStories': savedStories,
      'recentlyRead': recentlyRead,
    };
  }
}
