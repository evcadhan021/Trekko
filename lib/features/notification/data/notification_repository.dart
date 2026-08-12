import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    await firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,

      'isRead': false,

      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    final snapshot = await firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();
  }

  Stream<List<Map<String, dynamic>>> getUserNotificationsStream(String userId) {
    return firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();

          items.sort((a, b) {
            final aTs = a['createdAt'] as Timestamp?;
            final bTs = b['createdAt'] as Timestamp?;

            if (aTs == null && bTs == null) return 0;
            if (aTs == null) return 1;
            if (bTs == null) return -1;
            return bTs.compareTo(aTs);
          });

          return items;
        });
  }

  Stream<List<Map<String, dynamic>>> getAllNotificationsStream() {
    return firestore.collection('notifications').snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      items.sort((a, b) {
        final aTs = a['createdAt'] as Timestamp?;
        final bTs = b['createdAt'] as Timestamp?;

        if (aTs == null && bTs == null) return 0;
        if (aTs == null) return 1;
        if (bTs == null) return -1;
        return bTs.compareTo(aTs);
      });

      return items;
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }
}
