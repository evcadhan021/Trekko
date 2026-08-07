import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../rental/presentation/providers/rental_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/cart_provider.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final Set<String> selectedItems = {};

  DateTime? startDate;
  DateTime? endDate;

  Future<void> pickStartDate() async {
    final result = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (result == null) return;

    setState(() {
      startDate = result;
    });
  }

  Future<void> pickEndDate() async {
    final result = await showDatePicker(
      context: context,
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: startDate ?? DateTime.now(),
    );

    if (result == null) return;

    setState(() {
      endDate = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(userCartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Saya')),

      body: cartItems.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Keranjang masih kosong'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,

                      child: OutlinedButton(
                        onPressed: pickStartDate,

                        child: Text(
                          startDate == null
                              ? 'Pilih Tanggal Sewa'
                              : startDate.toString(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,

                      child: OutlinedButton(
                        onPressed: pickEndDate,

                        child: Text(
                          endDate == null
                              ? 'Pilih Tanggal Kembali'
                              : endDate.toString(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Dipilih: ${selectedItems.length} produk',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final id = item['id']?.toString() ?? index.toString();

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Checkbox(
                          value: selectedItems.contains(id),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedItems.add(id);
                              } else {
                                selectedItems.remove(id);
                              }
                            });
                          },
                        ),
                        title: Text(item['productName']?.toString() ?? ''),
                        subtitle: Text(
                          'Rp ${item['pricePerDay'] ?? ''} / hari',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, s) => Center(child: Text(e.toString())),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectedItems.isEmpty
            ? null
            : () async {
                if (startDate == null || endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pilih tanggal sewa terlebih dahulu'),
                    ),
                  );
                  return;
                }

                final user = FirebaseAuth.instance.currentUser;

                if (user == null) return;

                await ref
                    .read(cartRepositoryProvider)
                    .checkoutSelectedItems(
                      selectedItems.toList(),
                      user.uid,
                      startDate!,
                      endDate!,
                    );

                ref.invalidate(userCartProvider);

                ref.invalidate(userRentalsProvider);

                setState(() {
                  selectedItems.clear();
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checkout berhasil')),
                  );
                }
              },

        icon: const Icon(Icons.shopping_bag),

        label: Text(
          selectedItems.isEmpty
              ? 'Pilih Produk'
              : 'Checkout (${selectedItems.length})',
        ),
      ),
    );
  }
}
