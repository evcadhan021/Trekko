import 'package:cloud_firestore/cloud_firestore.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> markAllAsRead() async {
      final allNotifications = notifications.valueOrNull ?? const [];
      final unreadNotifications = allNotifications
          .where((item) => !(item['isRead'] as bool? ?? false))
          .toList();

      if (unreadNotifications.isEmpty) return;

      await Future.wait(
        unreadNotifications.map(
          (notification) => ref
              .read(notificationRepositoryProvider)
              .markAsRead(notification['id']),
        ),
      );

      ref.invalidate(userNotificationsProvider);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Notifikasi')),
      body: role.when(
        data: (value) {
          if (value?.toLowerCase() != 'user') {
            return Center(
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 36,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Akses notifikasi hanya untuk role user.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return notifications.when(
            data: (items) {
              final sortedItems = [...items]
                ..sort((a, b) {
                  final aTs = a['createdAt'] as Timestamp?;
                  final bTs = b['createdAt'] as Timestamp?;

                  if (aTs == null && bTs == null) return 0;
                  if (aTs == null) return 1;
                  if (bTs == null) return -1;
                  return bTs.compareTo(aTs);
                });

              final unreadCount = sortedItems
                  .where((item) => !(item['isRead'] as bool? ?? false))
                  .length;

              if (sortedItems.isEmpty) {
                return Center(
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            size: 36,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Belum ada notifikasi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Semua kabar dan status pesanan akan muncul di sini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.16),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status notifikasi',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                unreadCount > 0
                                    ? '$unreadCount belum dibaca'
                                    : 'Semua sudah dibaca',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (unreadCount > 0)
                          TextButton(
                            onPressed: markAllAsRead,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Baca semua'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...sortedItems.map((notification) {
                    final isRead = notification['isRead'] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isRead
                            ? Colors.white
                            : Colors.green.withValues(alpha: 0.05),
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
                              : colorScheme.primary.withValues(alpha: 0.12),
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
                                color: Colors.green,
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
                  }),
                ],
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
