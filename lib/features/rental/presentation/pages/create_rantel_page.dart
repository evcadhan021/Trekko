import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../product/domain/product_model.dart';
import '../providers/rental_provider.dart';

class CreateRentalPage extends ConsumerStatefulWidget {
  final ProductModel product;

  const CreateRentalPage({super.key, required this.product});

  @override
  ConsumerState<CreateRentalPage> createState() => _CreateRentalPageState();
}

class _CreateRentalPageState extends ConsumerState<CreateRentalPage> {
  DateTime? startDate;
  DateTime? endDate;

  String _formatDate(DateTime? date) {
    if (date == null) return 'Belum dipilih';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    int days = 0;

    if (startDate != null && endDate != null) {
      days = endDate!.difference(startDate!).inDays;
    }

    final total = days > 0 ? days * widget.product.pricePerDay : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Sewa Produk')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.product.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Rp ${widget.product.pricePerDay}/hari',
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
              ),
              const SizedBox(height: 18),
              _dateSelectionCard(
                title: 'Tanggal sewa',
                value: _formatDate(startDate),
                icon: Icons.calendar_month_rounded,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                    initialDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => startDate = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              _dateSelectionCard(
                title: 'Tanggal kembali',
                value: _formatDate(endDate),
                icon: Icons.event_available_rounded,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: startDate ?? DateTime.now(),
                    lastDate: DateTime(2030),
                    initialDate: startDate ?? DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => endDate = picked);
                  }
                },
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [const Text('Durasi'), Text('$days hari')],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total'),
                        Text(
                          'Rp $total',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (startDate == null || endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pilih tanggal terlebih dahulu'),
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

                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    final isAvailable = await ref
                        .read(rentalRepositoryProvider)
                        .isProductAvailable(
                          productId: widget.product.id,
                          startDate: startDate!,
                          endDate: endDate!,
                          stock: widget.product.stock,
                        );

                    if (!mounted) return;

                    if (!isAvailable) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Produk tidak tersedia pada tanggal tersebut',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    final profile = await ref
                        .read(authRepositoryProvider)
                        .getUserProfile(user.uid);
                    final userName = profile?['name'] ?? 'Unknown User';

                    await ref
                        .read(rentalRepositoryProvider)
                        .createRental(
                          userId: user.uid,
                          userName: userName,
                          productId: widget.product.id,
                          productName: widget.product.name,
                          startDate: startDate!,
                          endDate: endDate!,
                          totalDays: days,
                          pricePerDay: widget.product.pricePerDay,
                        );

                    ref.invalidate(userRentalsProvider);

                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Penyewaan berhasil dibuat'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    navigator.pop();
                  },
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Konfirmasi Sewa'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateSelectionCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
