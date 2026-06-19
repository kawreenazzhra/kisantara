import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';
import '../services/notification_service.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // ─────────────────────────────────────────────
  // CERITA CRUD
  // ─────────────────────────────────────────────

  /// Stream all APPROVED stories from Firestore for a specific language (newest first).
  /// Falls back to Bahasa Indonesia stories if none exist for the selected language.
  Stream<List<StoryModel>> getStories({String language = 'Bahasa Indonesia'}) {
    return _db
        .collection('stories')
        .snapshots()
        .map((snapshot) {
      final all = snapshot.docs.map((doc) => StoryModel.fromFirestore(doc)).toList();
      // Only approved stories
      final allApproved = all.where((s) => s.isApproved).toList();

      // Filter by requested language (legacy docs without language field default to Bahasa Indonesia)
      var langFiltered = allApproved.where((s) => s.language == language).toList();

      // Fallback: if no stories in selected language, show Bahasa Indonesia stories
      if (langFiltered.isEmpty && language != 'Bahasa Indonesia') {
        langFiltered = allApproved.where((s) => s.language == 'Bahasa Indonesia').toList();
      }

      langFiltered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return langFiltered;
    });
  }


  /// Stream ALL stories (for admin management panel — includes pending & rejected)
  Stream<List<StoryModel>> getAllStoriesForAdmin() {
    return _db
        .collection('stories')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => StoryModel.fromFirestore(doc)).toList();
      return list.where((s) => s.originalId.isEmpty).toList();
    });
  }

  /// Stream only PENDING stories (for admin approval queue)
  Stream<List<StoryModel>> getPendingStories() {
    return _db
        .collection('stories')
        .snapshots()
        .map((snapshot) {
      final all = snapshot.docs.map((doc) => StoryModel.fromFirestore(doc)).toList();
      final pending = all.where((s) => s.isPending && s.originalId.isEmpty).toList();
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
      final originalList = list.where((s) => s.originalId.isEmpty).toList();
      originalList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return originalList;
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
    final docRef = await _db.collection('stories').add(story.toMap());
    
    // If admin adds a story, it is approved by default
    if (story.status == 'approved') {
      await _notificationService.createNewStoryNotificationFromAdmin(
        storyId: docRef.id,
        storyTitle: story.title,
        category: story.category,
      );
    } else if (story.status == 'pending') {
      await _notificationService.createPendingStoryNotification(
        storyId: docRef.id,
        storyTitle: story.title,
        authorName: story.authorName ?? 'Pengguna',
      );
    }
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
    
    // Send notifications after approval
    final story = await getStoryById(id);
    if (story != null) {
      await _notificationService.createApprovalNotification(
        userId: story.authorId,
        storyId: story.id,
        storyTitle: story.title,
      );
      
      await _notificationService.createNewStoryNotificationFromUser(
        storyId: story.id,
        storyTitle: story.title,
        authorName: story.authorName,
        category: story.category,
      );
    }
  }

  /// Admin rejects a pending user story
  Future<void> rejectStory(String id) async {
    await _db.collection('stories').doc(id).update({'status': 'rejected'});
  }

  // ─────────────────────────────────────────────
  // BOOKMARKS (DISIMPAN)
  // ─────────────────────────────────────────────

  // Toggle bookmark state using story's canonical ID (original ID or its own ID)
  Future<void> toggleBookmark(String userId, StoryModel story) async {
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();
    if (!doc.exists) return;

    final user = UserModel.fromFirestore(doc);
    final canonicalId = story.canonicalId;

    if (user.savedStories.contains(canonicalId)) {
      // Remove from bookmarks
      await userRef.update({
        'savedStories': FieldValue.arrayRemove([canonicalId])
      });
    } else {
      // Add to bookmarks
      await userRef.update({
        'savedStories': FieldValue.arrayUnion([canonicalId])
      });
    }
  }

  // Stream bookmarked stories for a user, mapped to active language in-memory
  Stream<List<StoryModel>> getBookmarkedStories(String userId, {String language = 'Bahasa Indonesia'}) {
    return _db.collection('users').doc(userId).snapshots().asyncMap((userDoc) async {
      if (!userDoc.exists) return [];
      final user = UserModel.fromFirestore(userDoc);
      if (user.savedStories.isEmpty) return [];

      final storyQuery = await _db
          .collection('stories')
          .where(FieldPath.documentId, whereIn: user.savedStories.take(10).toList())
          .get();

      final bookmarkedStories = storyQuery.docs
          .map((doc) => StoryModel.fromFirestore(doc))
          .where((s) => s.isApproved)
          .toList();

      if (language == 'Bahasa Indonesia') {
        return bookmarkedStories;
      }

      // Fetch all approved stories for the requested language to map translations
      final translatedSnapshot = await _db
          .collection('stories')
          .where('language', isEqualTo: language)
          .where('status', isEqualTo: 'approved')
          .get();
      
      final translatedStories = translatedSnapshot.docs
          .map((doc) => StoryModel.fromFirestore(doc))
          .toList();

      final mappedList = <StoryModel>[];
      for (final story in bookmarkedStories) {
        if (story.language == language) {
          mappedList.add(story);
        } else {
          final targetOrigId = story.canonicalId;
          final translation = translatedStories.cast<StoryModel?>().firstWhere(
            (s) => s?.originalId == targetOrigId,
            orElse: () => null,
          );
          if (translation != null) {
            mappedList.add(translation);
          } else {
            mappedList.add(story);
          }
        }
      }
      return mappedList;
    });
  }

  // Check if a story is bookmarked by checking its canonical ID
  Stream<bool> isStoryBookmarked(String userId, StoryModel story) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return false;
      final user = UserModel.fromFirestore(doc);
      return user.savedStories.contains(story.canonicalId);
    });
  }

  // ─────────────────────────────────────────────
  // RECENTLY READ (TERAKHIR DIBACA)
  // ─────────────────────────────────────────────

  // Add story to recently read list using its canonical ID (max 5 items)
  Future<void> addToRecentlyRead(String userId, StoryModel story) async {
    final userRef = _db.collection('users').doc(userId);
    final doc = await userRef.get();
    if (!doc.exists) return;

    final user = UserModel.fromFirestore(doc);
    final canonicalId = story.canonicalId;
    List<String> list = List.from(user.recentlyRead);

    // Remove if already exists to push it to the front
    list.remove(canonicalId);
    list.insert(0, canonicalId);

    // Keep max 5 items
    if (list.length > 5) {
      list = list.sublist(0, 5);
    }

    await userRef.update({'recentlyRead': list});
  }

  // Stream recently read stories, mapped to active language in-memory
  Stream<List<StoryModel>> getRecentlyReadStories(String userId, {String language = 'Bahasa Indonesia'}) {
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

      if (language == 'Bahasa Indonesia') {
        return orderedStories;
      }

      // Fetch all approved stories for the requested language to map translations
      final translatedSnapshot = await _db
          .collection('stories')
          .where('language', isEqualTo: language)
          .where('status', isEqualTo: 'approved')
          .get();
      
      final translatedStories = translatedSnapshot.docs
          .map((doc) => StoryModel.fromFirestore(doc))
          .toList();

      final mappedList = <StoryModel>[];
      for (final story in orderedStories) {
        if (story.language == language) {
          mappedList.add(story);
        } else {
          final targetOrigId = story.canonicalId;
          final translation = translatedStories.cast<StoryModel?>().firstWhere(
            (s) => s?.originalId == targetOrigId,
            orElse: () => null,
          );
          if (translation != null) {
            mappedList.add(translation);
          } else {
            mappedList.add(story);
          }
        }
      }
      return mappedList;
    });
  }
}
