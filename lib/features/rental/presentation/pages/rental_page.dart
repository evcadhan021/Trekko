import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/rental_provider.dart';

class RentalPage extends ConsumerWidget {
  const RentalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rentals = ref.watch(userRentalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rental Saya')),

      body: rentals.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada penyewaan'));
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

                  trailing: rental['status'] == 'pending'
                      ? IconButton(
                          icon: const Icon(Icons.cancel),

                          onPressed: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              // Dialog Konfirmasi Pembatalan//
                              builder: (_) {
                                return AlertDialog(
                                  title: const Text('Batalkan Penyewaan?'),

                                  content: const Text(
                                    'Apakah Anda yakin ingin membatalkan penyewaan ini?',
                                  ),

                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },

                                      child: const Text('Tidak'),
                                    ),

                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },

                                      child: const Text('Ya'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (result != true) return;

                            await ref
                                .read(rentalRepositoryProvider)
                                .cancelRental(rental['id']);

                            ref.invalidate(userRentalsProvider);

                            ref.invalidate(rentalHistoryProvider);
                          },
                        )
                      : null,
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
