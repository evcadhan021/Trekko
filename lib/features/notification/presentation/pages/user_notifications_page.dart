import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/notification_provider.dart';

class UserNotificationsPage extends ConsumerWidget {
  const UserNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    final notifications = ref.watch(userNotificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: role.when(
        data: (value) {
          if (value?.toLowerCase() != 'user') {
            return const Center(
              child: Text('Akses notifikasi hanya untuk role user.'),
            );
          }

          return notifications.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text('Belum ada notifikasi'));
              }

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final notification = items[index];
                  final isRead = notification['isRead'] ?? false;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: isRead
                        ? null
                        : const Color.fromRGBO(33, 150, 243, 0.08),
                    child: ListTile(
                      leading: Icon(
                        isRead
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                      ),
                      title: Text(notification['title'].toString()),
                      subtitle: Text(notification['message'].toString()),
                      trailing: isRead
                          ? null
                          : const Icon(
                              Icons.fiber_manual_record,
                              size: 12,
                              color: Colors.blue,
                            ),
                      onTap: () async {
                        if (!isRead) {
                          await ref
                              .read(notificationRepositoryProvider)
                              .markAsRead(notification['id']);
                          ref.invalidate(userNotificationsProvider);
                        }
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text(e.toString())),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(e.toString())),
      ),
    );
  }
}
