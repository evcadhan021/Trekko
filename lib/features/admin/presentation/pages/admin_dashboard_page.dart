import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trekko/features/admin/presentation/pages/admin_rental_detal_page.dart';

import '../providers/admin_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rentals = ref.watch(allRentalsProvider);

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
            return const Center(child: Text('Belum ada rental'));
          }

          return ListView.builder(
            itemCount: items.length,

            itemBuilder: (context, index) {
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
            },
          );
        },

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, s) => Center(child: Text(e.toString())),
      ),
    );
  }
}
