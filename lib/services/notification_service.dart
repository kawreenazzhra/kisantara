import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get stream of notifications for current user (real-time)
  Stream<List<NotificationModel>> getUserNotifications() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _db
        .collection('notifications')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  /// Get unread notifications count for current user (real-time)
  Stream<int> getUnreadNotificationsCount() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(0);
    }

    return _db
        .collection('notifications')
        .where('userId', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _db
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read for current user
  Future<void> markAllAsRead() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final unreadDocs = await _db
          .collection('notifications')
          .where('userId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadDocs.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  /// Delete all notifications for current user
  Future<void> deleteAllNotifications() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final docs = await _db
          .collection('notifications')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      final batch = _db.batch();
      for (var doc in docs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error deleting all notifications: $e');
    }
  }

  /// Create approval notification (called by admin when approving story)
  Future<void> createApprovalNotification({
    required String userId,
    required String storyId,
    required String storyTitle,
  }) async {
    try {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        type: 'approval',
        title: 'Cerita Disetujui',
        message: 'Cerita "$storyTitle" kamu telah disetujui oleh admin dan sudah dipublikasikan!',
        storyId: storyId,
        storyTitle: storyTitle,
        timestamp: DateTime.now(),
      );

      await _db.collection('notifications').add(notification.toFirestore());
    } catch (e) {
      print('Error creating approval notification: $e');
    }
  }

  /// Create new story notification (called when admin posts new story)
  Future<void> createNewStoryNotificationFromAdmin({
    required String storyId,
    required String storyTitle,
    required String? category,
  }) async {
    try {
      // Get all users
      final usersSnapshot = await _db.collection('users').get();

      final notification = NotificationModel(
        id: '',
        userId: '', // Will be set per user
        type: 'new_story_admin',
        title: 'Cerita Baru dari Admin',
        message: 'Admin telah memposting cerita baru: "$storyTitle"${category != null ? ' dengan kategori $category' : ''}',
        storyId: storyId,
        storyTitle: storyTitle,
        authorName: 'Admin Kisantara',
        category: category,
        timestamp: DateTime.now(),
      );

      // Send to all users
      for (var userDoc in usersSnapshot.docs) {
        final notif = NotificationModel(
          id: '',
          userId: userDoc.id,
          type: notification.type,
          title: notification.title,
          message: notification.message,
          storyId: notification.storyId,
          storyTitle: notification.storyTitle,
          authorName: notification.authorName,
          category: notification.category,
          timestamp: notification.timestamp,
        );
        await _db.collection('notifications').add(notif.toFirestore());
      }
    } catch (e) {
      print('Error creating new story notification from admin: $e');
    }
  }

  /// Create new story notification (called when user posts new approved story)
  Future<void> createNewStoryNotificationFromUser({
    required String storyId,
    required String storyTitle,
    required String authorName,
    required String? category,
  }) async {
    try {
      // Get all users except the author
      final usersSnapshot = await _db.collection('users').get();
      final authorDoc = await _db.collection('users').where('name', isEqualTo: authorName).get();
      final authorId = authorDoc.docs.isNotEmpty ? authorDoc.docs.first.id : '';

      final notification = NotificationModel(
        id: '',
        userId: '', // Will be set per user
        type: 'new_story_user',
        title: 'Cerita Baru dari Pengguna',
        message: 'Pengguna "$authorName" telah mempublikasikan cerita baru: "$storyTitle"',
        storyId: storyId,
        storyTitle: storyTitle,
        authorName: authorName,
        authorId: authorId,
        category: category,
        timestamp: DateTime.now(),
      );

      // Send to all users except author
      for (var userDoc in usersSnapshot.docs) {
        if (userDoc.id != authorId) {
          final notif = NotificationModel(
            id: '',
            userId: userDoc.id,
            type: notification.type,
            title: notification.title,
            message: notification.message,
            storyId: notification.storyId,
            storyTitle: notification.storyTitle,
            authorName: notification.authorName,
            authorId: notification.authorId,
            category: notification.category,
            timestamp: notification.timestamp,
          );
          await _db.collection('notifications').add(notif.toFirestore());
        }
      }
    } catch (e) {
      print('Error creating new story notification from user: $e');
    }
  }

  /// Create pending story notification (called when user posts new pending story)
  Future<void> createPendingStoryNotification({
    required String storyId,
    required String storyTitle,
    required String authorName,
  }) async {
    try {
      // Get all admins
      final adminsSnapshot = await _db.collection('users').where('role', isEqualTo: 'admin').get();

      final notification = NotificationModel(
        id: '',
        userId: '', // Will be set per admin
        type: 'pending_story',
        title: 'Cerita Perlu Persetujuan',
        message: 'Pengguna "$authorName" telah mengirimkan cerita baru: "$storyTitle" dan menunggu persetujuan.',
        storyId: storyId,
        storyTitle: storyTitle,
        authorName: authorName,
        timestamp: DateTime.now(),
      );

      // Send to all admins
      for (var adminDoc in adminsSnapshot.docs) {
        final notif = NotificationModel(
          id: '',
          userId: adminDoc.id,
          type: notification.type,
          title: notification.title,
          message: notification.message,
          storyId: notification.storyId,
          storyTitle: notification.storyTitle,
          authorName: notification.authorName,
          timestamp: notification.timestamp,
        );
        await _db.collection('notifications').add(notif.toFirestore());
      }
    } catch (e) {
      print('Error creating pending story notification: $e');
    }
  }
}
