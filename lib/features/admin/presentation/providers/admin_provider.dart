import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/admin_constants.dart';
import '../../data/admin_repository.dart';
import '../../../chat/data/chat_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final allRentalsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  return ref.read(adminRepositoryProvider).getAllRentals();
});

final adminChatUnreadCountProvider = FutureProvider<int>((ref) async {
  final chatRepository = ChatRepository();
  final sessions = await chatRepository.getChatSessions();

  var totalUnread = 0;
  for (final session in sessions) {
    final userId = (session['userId'] ?? '').toString();
    if (userId.isEmpty) continue;

    final messages = await chatRepository.firestore
        .collection('admin_chats')
        .doc(userId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();

    totalUnread += messages.docs.where((doc) {
      final senderId = (doc.data()['senderId'] ?? '').toString();
      return senderId != AdminConstants.adminUid;
    }).length;
  }

  return totalUnread;
});
