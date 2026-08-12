import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../rental/presentation/providers/rental_provider.dart';
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
    setState(() => startDate = result);
  }

  Future<void> pickEndDate() async {
    final result = await showDatePicker(
      context: context,
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: startDate ?? DateTime.now(),
    );

    if (result == null) return;
    setState(() => endDate = result);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Belum dipilih';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(userCartProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Keranjang Saya')),
      body: cartItems.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
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
                          Icons.shopping_bag_outlined,
                          size: 36,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Keranjang masih kosong',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tambahkan produk favorit Anda untuk memulai sewa.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF64748B), height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, const Color(0xFF0F172A)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pilihan Anda',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${selectedItems.length} produk dipilih',
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
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _dateCard(
                          title: 'Tanggal sewa',
                          value: _formatDate(startDate),
                          icon: Icons.calendar_month_rounded,
                          onTap: pickStartDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dateCard(
                          title: 'Tanggal kembali',
                          value: _formatDate(endDate),
                          icon: Icons.event_available_rounded,
                          onTap: pickEndDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final id = item['id']?.toString() ?? index.toString();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
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
                          child: Row(
                            children: [
                              Checkbox(
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
                              const SizedBox(width: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item['imageUrl']?.toString() ?? '',
                                  width: 62,
                                  height: 62,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 62,
                                    height: 62,
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['productName']?.toString() ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${item['pricePerDay'] ?? 0} / hari',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
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
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (endDate!.isBefore(startDate!)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tanggal kembali tidak boleh lebih awal dari tanggal sewa',
                      ),
                      behavior: SnackBarBehavior.floating,
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
                setState(() => selectedItems.clear());

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Checkout berhasil'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
        icon: const Icon(Icons.shopping_bag_rounded),
        label: Text(
          selectedItems.isEmpty
              ? 'Pilih Produk'
              : 'Checkout (${selectedItems.length})',
        ),
      ),
    );
  }

  Widget _dateCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
