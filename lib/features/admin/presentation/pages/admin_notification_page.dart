import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notification/presentation/providers/notification_provider.dart';

class AdminNotificationsPage extends ConsumerWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(userNotificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi Admin')),

      body: notifications.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada notifikasi'));
          }

          return ListView.builder(
            itemCount: items.length,

            itemBuilder: (context, index) {
              final notification = items[index];

              return Card(
                margin: const EdgeInsets.all(8),

                child: ListTile(
                  leading: const Icon(Icons.notifications),

                  title: Text(notification['title'].toString()),

                  subtitle: Text(notification['message'].toString()),
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
