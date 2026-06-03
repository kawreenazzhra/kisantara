import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────
  // CERITA CRUD
  // ─────────────────────────────────────────────

  /// Stream all APPROVED stories from Firestore (newest first)
  Stream<List<StoryModel>> getStories() {
    return _db
        .collection('stories')
        .snapshots()
        .map((snapshot) {
      final all = snapshot.docs.map((doc) => StoryModel.fromFirestore(doc)).toList();
      // Filter to approved only (or legacy docs without status field which default to approved)
      final approved = all.where((s) => s.isApproved).toList();
      approved.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return approved;
    });
  }

  /// Stream ALL stories (for admin management panel — includes pending & rejected)
  Stream<List<StoryModel>> getAllStoriesForAdmin() {
    return _db
        .collection('stories')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => StoryModel.fromFirestore(doc)).toList();
    });
  }

  /// Stream only PENDING stories (for admin approval queue)
  Stream<List<StoryModel>> getPendingStories() {
    return _db
        .collection('stories')
        .snapshots()
        .map((snapshot) {
      final all = snapshot.docs.map((doc) => StoryModel.fromFirestore(doc)).toList();
      final pending = all.where((s) => s.isPending).toList();
      pending.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return pending;
    });
  }

  // Stream stories written by a specific user (all statuses)
  Stream<List<StoryModel>> getUserStories(String userId) {
    return _db
        .collection('stories')
        .where('authorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => StoryModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  // Get single story by ID
  Future<StoryModel?> getStoryById(String id) async {
    try {
      final doc = await _db.collection('stories').doc(id).get();
      if (doc.exists) {
        return StoryModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error getting story: $e');
    }
    return null;
  }

  // Add new story
  Future<void> addStory(StoryModel story) async {
    await _db.collection('stories').add(story.toMap());
  }

  // Update existing story
  Future<void> updateStory(String id, Map<String, dynamic> data) async {
    await _db.collection('stories').doc(id).update(data);
  }

  // Delete story
  Future<void> deleteStory(String id) async {
    await _db.collection('stories').doc(id).delete();
  }

  /// Admin approves a pending user story
  Future<void> approveStory(String id) async {
    await _db.collection('stories').doc(id).update({'status': 'approved'});
  }

  /// Admin rejects a pending user story
  Future<void> rejectStory(String id) async {
    await _db.collection('stories').doc(id).update({'status': 'rejected'});
  }

  // ─────────────────────────────────────────────
  // BOOKMARKS (DISIMPAN)
  // ─────────────────────────────────────────────

  // Toggle bookmark state
  Future<void> toggleBookmark(String userId, String storyId) async {
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();
    if (!doc.exists) return;

    final user = UserModel.fromFirestore(doc);
    if (user.savedStories.contains(storyId)) {
      // Remove from bookmarks
      await userRef.update({
        'savedStories': FieldValue.arrayRemove([storyId])
      });
    } else {
      // Add to bookmarks
      await userRef.update({
        'savedStories': FieldValue.arrayUnion([storyId])
      });
    }
  }

  // Stream bookmarked stories for a user
  Stream<List<StoryModel>> getBookmarkedStories(String userId) {
    return _db.collection('users').doc(userId).snapshots().asyncMap((userDoc) async {
      if (!userDoc.exists) return [];
      final user = UserModel.fromFirestore(userDoc);
      if (user.savedStories.isEmpty) return [];

      final storyQuery = await _db
          .collection('stories')
          .where(FieldPath.documentId, whereIn: user.savedStories.take(10).toList())
          .get();

      return storyQuery.docs
          .map((doc) => StoryModel.fromFirestore(doc))
          .where((s) => s.isApproved)
          .toList();
    });
  }

  // Check if a story is bookmarked by a user
  Stream<bool> isStoryBookmarked(String userId, String storyId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return false;
      final user = UserModel.fromFirestore(doc);
      return user.savedStories.contains(storyId);
    });
  }

  // ─────────────────────────────────────────────
  // RECENTLY READ (TERAKHIR DIBACA)
  // ─────────────────────────────────────────────

  // Add story to recently read list (max 5 items)
  Future<void> addToRecentlyRead(String userId, String storyId) async {
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();
    if (!doc.exists) return;

    final user = UserModel.fromFirestore(doc);
    List<String> list = List.from(user.recentlyRead);

    // Remove if already exists to push it to the front
    list.remove(storyId);
    list.insert(0, storyId);

    // Keep max 5 items
    if (list.length > 5) {
      list = list.sublist(0, 5);
    }

    await userRef.update({'recentlyRead': list});
  }

  // Stream recently read stories
  Stream<List<StoryModel>> getRecentlyReadStories(String userId) {
    return _db.collection('users').doc(userId).snapshots().asyncMap((userDoc) async {
      if (!userDoc.exists) return [];
      final user = UserModel.fromFirestore(userDoc);
      if (user.recentlyRead.isEmpty) return [];

      final storyQuery = await _db
          .collection('stories')
          .where(FieldPath.documentId, whereIn: user.recentlyRead.take(5).toList())
          .get();

      // Sort according to user's recentlyRead ordering
      final stories = storyQuery.docs.map((doc) => StoryModel.fromFirestore(doc)).toList();
      final orderedStories = <StoryModel>[];
      for (final id in user.recentlyRead) {
        final match = stories.cast<StoryModel?>().firstWhere(
              (s) => s?.id == id,
              orElse: () => null,
            );
        if (match != null) {
          orderedStories.add(match);
        }
      }
      return orderedStories;
    });
  }
}
