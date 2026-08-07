import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final userNotificationsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return [];
  }

  return ref
      .read(notificationRepositoryProvider)
      .getUserNotifications(user.uid);
});
