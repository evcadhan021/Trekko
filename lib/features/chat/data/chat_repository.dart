import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trekko/core/constants/admin_constants.dart';

class ChatRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> sendMessageToAdmin({
    required String userId,
    required String userName,
    required String productName,
    required String message,
    String? productId,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    final chatRef = firestore.collection('admin_chats').doc(userId);
    final now = FieldValue.serverTimestamp();

    final doc = await chatRef.get();

    if (!doc.exists) {
      await chatRef.set({
        'userId': userId,
        'userName': userName,
        'adminId': AdminConstants.adminUid,
        'productId': productId ?? '',
        'productName': productName,
        'lastMessage': trimmed,
        'updatedAt': now,
        'createdAt': now,
      });
    } else {
      await chatRef.update({
        'userName': userName,
        'productId': productId ?? doc.data()?['productId'] ?? '',
        'productName': productName,
        'lastMessage': trimmed,
        'updatedAt': now,
      });
    }

    await chatRef.collection('messages').add({
      'senderId': userId,
      'senderRole': 'user',
      'message': trimmed,
      'createdAt': now,
    });

    await firestore.collection('notifications').add({
      'userId': AdminConstants.adminUid,
      'title': 'Chat baru dari pelanggan',
      'message': '$userName menanyakan produk "$productName".',
      'isRead': false,
      'createdAt': now,
    });
  }

  Future<void> sendAdminReply({
    required String userId,
    required String adminId,
    required String message,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    final chatRef = firestore.collection('admin_chats').doc(userId);
    final now = FieldValue.serverTimestamp();

    await chatRef.set({
      'userId': userId,
      'adminId': adminId,
      'lastMessage': trimmed,
      'updatedAt': now,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await chatRef.collection('messages').add({
      'senderId': adminId,
      'senderRole': 'admin',
      'message': trimmed,
      'createdAt': now,
    });
  }

  Stream<List<Map<String, dynamic>>> getMessagesStream(String userId) {
    return firestore
        .collection('admin_chats')
        .doc(userId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<List<Map<String, dynamic>>> getChatSessions() async {
    final snapshot = await firestore.collection('admin_chats').get();

    final items = snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();

    items.sort((a, b) {
      final aTs = a['updatedAt'] as Timestamp?;
      final bTs = b['updatedAt'] as Timestamp?;

      if (aTs == null && bTs == null) return 0;
      if (aTs == null) return 1;
      if (bTs == null) return -1;
      return bTs.compareTo(aTs);
    });

    return items;
  }
}
