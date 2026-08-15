import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trekko/core/constants/admin_constants.dart';

class ChatRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static String resolveDisplayName({
    required String? userName,
    required Map<String, dynamic>? userProfile,
    required String fallback,
  }) {
    final profileName = (userProfile?['name'] ?? '').toString().trim();
    final profileEmail = (userProfile?['email'] ?? '').toString().trim();
    final authName = (userName ?? '').trim();

    if (profileName.isNotEmpty) return profileName;
    if (authName.isNotEmpty && authName.toLowerCase() != 'user') {
      return authName;
    }
    if (profileEmail.isNotEmpty) {
      return profileEmail.split('@').first;
    }
    return fallback;
  }

  Future<String> getUserDisplayName(String userId) async {
    final userDoc = await firestore.collection('users').doc(userId).get();
    final data = userDoc.data();

    if (data == null) {
      return 'Pelanggan';
    }

    final profileName = (data['name'] ?? '').toString().trim();
    if (profileName.isNotEmpty && profileName.toLowerCase() != 'user') {
      return profileName;
    }

    final email = (data['email'] ?? '').toString().trim();
    if (email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Pelanggan';
  }

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

    final normalizedName = (userName.trim().isNotEmpty)
        ? userName.trim()
        : await getUserDisplayName(userId);

    if (!doc.exists) {
      await chatRef.set({
        'userId': userId,
        'userName': normalizedName,
        'adminId': AdminConstants.adminUid,
        'productId': productId ?? '',
        'productName': productName,
        'lastMessage': trimmed,
        'updatedAt': now,
        'createdAt': now,
      });
    } else {
      await chatRef.update({
        'userName': normalizedName,
        'productId': productId ?? doc.data()?['productId'] ?? '',
        'productName': productName,
        'lastMessage': trimmed,
        'updatedAt': now,
      });
    }

    await chatRef.collection('messages').add({
      'senderId': userId,
      'senderRole': 'user',
      'senderName': normalizedName,
      'message': trimmed,
      'isRead': false,
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

    final messageRef = await chatRef.collection('messages').add({
      'senderId': adminId,
      'senderRole': 'admin',
      'senderName': 'Admin',
      'message': trimmed,
      'isRead': false,
      'createdAt': now,
    });

    await firestore.collection('notifications').add({
      'userId': userId,
      'title': 'Balasan dari Admin',
      'message': 'Admin telah membalas chat Anda.',
      'isRead': false,
      'createdAt': now,
    });

    await messageRef.update({'isRead': false});
  }

  Future<void> markAllAdminMessagesAsRead(String userId) async {
    final snapshot = await firestore
        .collection('admin_chats')
        .doc(userId)
        .collection('messages')
        .where('senderId', isEqualTo: AdminConstants.adminUid)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Future<void> markAllUserMessagesAsRead(String userId) async {
    final snapshot = await firestore
        .collection('admin_chats')
        .doc(userId)
        .collection('messages')
        .where('senderId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Future<int> getUnreadAdminReplyCount(String userId) async {
    final snapshot = await firestore
        .collection('admin_chats')
        .doc(userId)
        .collection('messages')
        .where('senderId', isEqualTo: AdminConstants.adminUid)
        .where('isRead', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }

  Future<int> getUnreadUserMessagesCount(String userId) async {
    final snapshot = await firestore
        .collection('admin_chats')
        .doc(userId)
        .collection('messages')
        .where('senderId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    return snapshot.docs.length;
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

    final items = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final rawUserName = (data['userName'] ?? '').toString().trim();
      final userId = (data['userId'] ?? doc.id).toString();
      final unreadCount = await getUnreadUserMessagesCount(userId);

      final resolvedName =
          rawUserName.isNotEmpty && rawUserName.toLowerCase() != 'user'
          ? rawUserName
          : await getUserDisplayName(userId);

      items.add({
        'id': doc.id,
        ...data,
        'userId': userId,
        'userName': resolvedName,
        'unreadCount': unreadCount,
      });
    }

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
