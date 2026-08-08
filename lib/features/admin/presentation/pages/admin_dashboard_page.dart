import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trekko/features/admin/presentation/pages/admin_rental_detal_page.dart';
import 'package:trekko/features/notification/presentation/providers/notification_provider.dart';

import '../providers/admin_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rentals = ref.watch(allRentalsProvider);
    final notifications = ref.watch(userNotificationsProvider);

    final notificationTile = notifications.when(
      data: (items) {
        final unreadCount = items
            .where((item) => !(item['isRead'] as bool? ?? false))
            .length;
        final unreadLabel = unreadCount > 99 ? '99+' : unreadCount.toString();

        return ListTile(
          leading: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.notifications),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          title: const Text('Notifikasi'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push('/admin-notifications');
          },
        );
      },
      loading: () => ListTile(
        leading: const Icon(Icons.notifications),
        title: const Text('Notifikasi'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.push('/admin-notifications');
        },
      ),
      error: (e, s) => ListTile(
        leading: const Icon(Icons.notifications),
        title: const Text('Notifikasi'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.push('/admin-notifications');
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory),
            onPressed: () {
              context.push('/admin-products');
            },
          ),
        ],
      ),

      body: rentals.when(
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              children: [
                notificationTile,
                const Center(child: Text('Belum ada rental')),
              ],
            );
          }

          return ListView(
            children: [
              notificationTile,
              ...List.generate(items.length, (index) {
                final rental = items[index];

                return Card(
                  margin: const EdgeInsets.all(8),

                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminRentalDetailPage(rental: rental),
                        ),
                      );
                    },
                    title: Text(rental['productName'].toString()),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text('Penyewa: ${rental['userName'] ?? '-'}'),

                        Text('Status: ${rental['status']}'),

                        Text('${rental['totalDays']} hari'),

                        Text('Rp ${rental['totalPrice']}'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        await ref
                            .read(adminRepositoryProvider)
                            .updateRentalStatus(
                              rentalId: rental['id'],
                              status: value,
                            );

                        ref.invalidate(allRentalsProvider);
                      },

                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'confirmed',
                          child: Text('Confirm'),
                        ),

                        const PopupMenuItem(
                          value: 'active',
                          child: Text('Active'),
                        ),

                        const PopupMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),

                        const PopupMenuItem(
                          value: 'cancelled_by_admin',
                          child: Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, s) => Center(child: Text(e.toString())),
      ),
    );
  }
}
