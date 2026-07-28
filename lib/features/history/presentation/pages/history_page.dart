import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../rental/presentation/providers/rental_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final histories = ref.watch(rentalHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Penyewaan')),

      body: histories.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada riwayat'));
          }

          return ListView.builder(
            itemCount: items.length,

            itemBuilder: (context, index) {
              final rental = items[index];

              return Card(
                margin: const EdgeInsets.all(8),

                child: ListTile(
                  title: Text(rental['productName'].toString()),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text('${rental['totalDays']} hari'),

                      Text('Rp ${rental['totalPrice']}'),

                      Text('Status: ${rental['status']}'),
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
