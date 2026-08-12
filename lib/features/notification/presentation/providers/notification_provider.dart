import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final userNotificationsProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return Stream.value(<Map<String, dynamic>>[]);
  }

  return ref
      .read(notificationRepositoryProvider)
      .getUserNotificationsStream(user.uid);
});

final adminNotificationsProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  return ref.read(notificationRepositoryProvider).getAllNotificationsStream();
});
