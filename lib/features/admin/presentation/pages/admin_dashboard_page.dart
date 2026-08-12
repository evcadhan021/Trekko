import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trekko/features/admin/presentation/pages/admin_notification_page.dart';
import 'package:trekko/features/admin/presentation/pages/admin_products_page.dart';
import 'package:trekko/features/admin/presentation/pages/admin_rental_detal_page.dart';
import 'package:trekko/features/chat/presentation/pages/admin_chat_list_page.dart';
import 'package:trekko/features/notification/presentation/providers/notification_provider.dart';

import '../providers/admin_provider.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final rentals = ref.watch(allRentalsProvider);
    final notifications = ref.watch(userNotificationsProvider);
    final colorScheme = Theme.of(context).colorScheme;

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
              const Icon(Icons.notifications_outlined),
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
            setState(() {
              _currentIndex = 3;
            });
          },
        );
      },
      loading: () => ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: const Text('Notifikasi'),
        trailing: const Icon(Icons.chevron_right),
      ),
      error: (e, s) => ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: const Text('Notifikasi'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );

    final dashboardContent = rentals.when(
      data: (items) {
        if (items.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              notificationTile,
              const SizedBox(height: 12),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Belum ada rental'),
                ),
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            notificationTile,
            const SizedBox(height: 12),
            ...List.generate(items.length, (index) {
              final rental = items[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminRentalDetailPage(rental: rental),
                      ),
                    );
                  },
                  title: Text(
                    rental['productName'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
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
    );

    final pages = [
      dashboardContent,
      const AdminProductsPage(),
      const AdminChatListPage(),
      const AdminNotificationsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_outlined),
            onPressed: () {
              context.push('/admin-products');
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () {
              context.push('/admin-chat-list');
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 14,
          right: 14,
          bottom: MediaQuery.of(context).padding.bottom + 8,
          top: 8,
        ),
        decoration: const BoxDecoration(color: Colors.transparent),
        child: SafeArea(
          top: false,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: NavigationBar(
                height: 72,
                backgroundColor: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard_rounded),
                    label: 'Dashboard',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2_rounded),
                    label: 'Produk',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.chat_bubble_outline_rounded),
                    selectedIcon: Icon(Icons.chat_bubble_rounded),
                    label: 'Chat',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.notifications_none_rounded),
                    selectedIcon: Icon(Icons.notifications_rounded),
                    label: 'Notifikasi',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
