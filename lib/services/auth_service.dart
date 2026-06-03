import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current Firebase user
  User? get currentUser => _auth.currentUser;

  // Sign In with Email and Password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register with Email, Password, and Pen Name
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String penName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user?.uid;
    if (uid != null) {
      // Determine role based on email (admin@admin.com is admin)
      final role = (email.trim().toLowerCase() == 'admin@admin.com') ? 'admin' : 'user';

      // Create a profile document in Firestore
      final userModel = UserModel(
        uid: uid,
        email: email.trim(),
        penName: penName.trim(),
        role: role,
        bio: '',
        language: 'Bahasa Indonesia',
        savedStories: [],
        recentlyRead: [],
      );

      await _db.collection('users').doc(uid).set(userModel.toMap());
    }

    return credential;
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get User Profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error getting user profile: $e');
    }
    return null;
  }

  // Update User Profile
  Future<void> updateUserProfile({
    required String uid,
    required String penName,
    required String bio,
  }) async {
    await _db.collection('users').doc(uid).update({
      'penName': penName,
      'bio': bio,
    });
  }

  // Update User Language
  Future<void> updateUserLanguage({
    required String uid,
    required String language,
  }) async {
    await _db.collection('users').doc(uid).update({
      'language': language,
    });
  }
}
