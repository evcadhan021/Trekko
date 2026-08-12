import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trekko/features/admin/presentation/pages/admin_notification_page.dart';
import 'package:trekko/features/admin/presentation/pages/admin_products_page.dart';
import 'package:trekko/features/admin/presentation/pages/admin_rental_detal_page.dart';
import 'package:trekko/features/chat/presentation/pages/admin_chat_list_page.dart';
import 'package:trekko/features/notification/presentation/providers/notification_provider.dart';
import 'package:trekko/features/rental/presentation/providers/rental_provider.dart';

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
    final notifications = ref.watch(adminNotificationsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final unreadCount = notifications.maybeWhen(
      data: (items) =>
          items.where((item) => !(item['isRead'] as bool? ?? false)).length,
      orElse: () => 0,
    );

    final notificationTile = notifications.when(
      data: (items) {
        final unreadCountValue = items
            .where((item) => !(item['isRead'] as bool? ?? false))
            .length;
        final unreadLabel = unreadCountValue > 99
            ? '99+'
            : unreadCountValue.toString();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    color: colorScheme.primary,
                  ),
                ),
                if (unreadCountValue > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
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
            subtitle: Text(
              unreadCountValue > 0
                  ? '$unreadCountValue belum dibaca'
                  : 'Semua notifikasi sudah dibaca',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              setState(() {
                _currentIndex = 3;
              });
            },
          ),
        );
      },
      loading: () => const ListTile(
        leading: Icon(Icons.notifications_outlined),
        title: Text('Notifikasi'),
        trailing: Icon(Icons.chevron_right),
      ),
      error: (e, s) => const ListTile(
        leading: Icon(Icons.notifications_outlined),
        title: Text('Notifikasi'),
        trailing: Icon(Icons.chevron_right),
      ),
    );

    final dashboardContent = rentals.when(
      data: (items) {
        final activeCount = items
            .where((r) => (r['status'] ?? '').toString() == 'active')
            .length;
        final pendingCount = items
            .where((r) => (r['status'] ?? '').toString() == 'pending')
            .length;

        if (items.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              _headerCard(colorScheme, unreadCount),
              const SizedBox(height: 16),
              notificationTile,
              const SizedBox(height: 16),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Belum ada rental'),
                ),
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            _headerCard(colorScheme, unreadCount),
            const SizedBox(height: 16),
            notificationTile,
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Total',
                    value: items.length.toString(),
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    icon: Icons.pending_actions_rounded,
                    label: 'Pending',
                    value: pendingCount.toString(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    icon: Icons.play_circle_outline_rounded,
                    label: 'Active',
                    value: activeCount.toString(),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...List.generate(items.length, (index) {
              final rental = items[index];
              final status = (rental['status'] ?? '').toString();
              final statusColor = _statusColor(status);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminRentalDetailPage(rental: rental),
                      ),
                    );
                  },
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          rental['productName'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Penyewa: ${rental['userName'] ?? '-'}'),
                        const SizedBox(height: 4),
                        Text('${rental['totalDays']} hari'),
                        const SizedBox(height: 4),
                        Text('Rp ${rental['totalPrice']}'),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text('Hapus rental?'),
                              content: const Text(
                                'Data rental ini akan dihapus dari semua laporan dan history. Lanjutkan?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm != true) return;

                        await ref
                            .read(rentalRepositoryProvider)
                            .deleteRental(rental['id']);
                        ref.invalidate(allRentalsProvider);
                        ref.invalidate(userRentalsProvider);
                        ref.invalidate(rentalHistoryProvider);
                        return;
                      }

                      await ref
                          .read(adminRepositoryProvider)
                          .updateRentalStatus(
                            rentalId: rental['id'],
                            status: value,
                          );

                      ref.invalidate(allRentalsProvider);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'confirmed', child: Text('Confirm')),
                      PopupMenuItem(value: 'active', child: Text('Active')),
                      PopupMenuItem(
                        value: 'completed',
                        child: Text('Completed'),
                      ),
                      PopupMenuItem(
                        value: 'cancelled_by_admin',
                        child: Text('Cancel'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
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
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Hapus semua data rental',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text('Hapus semua data rental?'),
                    content: const Text(
                      'Semua data rental akan dihapus dari sistem. Tindakan ini tidak bisa dibatalkan. Lanjutkan?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Hapus semua'),
                      ),
                    ],
                  );
                },
              );

              if (confirm != true) return;

              await ref.read(rentalRepositoryProvider).deleteAllRentals();
              ref.invalidate(allRentalsProvider);
              ref.invalidate(userRentalsProvider);
              ref.invalidate(rentalHistoryProvider);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua data rental berhasil dihapus.'),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.inventory_outlined),
            onPressed: () => context.push('/admin-products'),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () => context.push('/admin-chat-list'),
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
        child: SafeArea(
          top: false,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E9E5A),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E9E5A).withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  navigationBarTheme: NavigationBarThemeData(
                    backgroundColor: const Color(0xFF1E9E5A),
                    surfaceTintColor: Colors.transparent,
                    indicatorColor: Colors.white.withValues(alpha: 0.18),
                    iconTheme: WidgetStateProperty.resolveWith((states) {
                      return const IconThemeData(color: Colors.white);
                    }),
                    labelTextStyle: WidgetStateProperty.resolveWith((states) {
                      return const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      );
                    }),
                  ),
                ),
                child: NavigationBar(
                  height: 72,
                  backgroundColor: const Color(0xFF1E9E5A),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  indicatorColor: Colors.white.withValues(alpha: 0.18),
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
                      icon: Icon(Icons.dashboard_outlined, color: Colors.white),
                      selectedIcon: Icon(
                        Icons.dashboard_rounded,
                        color: Colors.white,
                      ),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.white,
                      ),
                      selectedIcon: Icon(
                        Icons.inventory_2_rounded,
                        color: Colors.white,
                      ),
                      label: 'Produk',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Colors.white,
                      ),
                      selectedIcon: Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                      ),
                      label: 'Chat',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                      ),
                      selectedIcon: Icon(
                        Icons.notifications_rounded,
                        color: Colors.white,
                      ),
                      label: 'Notifikasi',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCard(ColorScheme colorScheme, int unreadCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, const Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Operasional',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  unreadCount > 0
                      ? '$unreadCount butuh perhatian'
                      : 'Semua berjalan lancar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      case 'cancelled_by_admin':
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
