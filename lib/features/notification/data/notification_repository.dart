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
        .get();

    return snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();
  }
}
