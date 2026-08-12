import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notification/presentation/providers/notification_provider.dart';

class AdminNotificationsPage extends ConsumerWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(adminNotificationsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi Admin')),
      body: notifications.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 42,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      const Text('Belum ada notifikasi'),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final notification = items[index];
              final isRead = notification['isRead'] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isRead
                      ? Colors.white
                      : Colors.blue.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    backgroundColor: isRead
                        ? Colors.grey.shade200
                        : colorScheme.primary.withValues(alpha: 0.14),
                    child: Icon(
                      isRead
                          ? Icons.notifications_none_rounded
                          : Icons.notifications_active_rounded,
                      color: isRead
                          ? Colors.grey.shade700
                          : colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    notification['title'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(notification['message'].toString()),
                  ),
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
      ),
    );
  }
}
