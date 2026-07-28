import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final daysController = TextEditingController(text: '1');
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    int days = 0;

    if (startDate != null && endDate != null) {
      days = endDate!.difference(startDate!).inDays;
    }

    final total = days * widget.product.pricePerDay;

    return Scaffold(
      appBar: AppBar(title: const Text('Sewa Produk')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Text(widget.product.name),

            const SizedBox(height: 16),

            Text('Rp ${widget.product.pricePerDay}/hari'),

            const SizedBox(height: 16),

            ListTile(
              title: Text(
                startDate == null
                    ? 'Pilih Tanggal Sewa'
                    : startDate.toString().split(' ')[0],
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                  initialDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    startDate = picked;
                  });
                }
              },
            ),

            ListTile(
              title: Text(
                endDate == null
                    ? 'Pilih Tanggal Kembali'
                    : endDate.toString().split(' ')[0],
              ),
              trailing: const Icon(Icons.event),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: startDate ?? DateTime.now(),
                  lastDate: DateTime(2030),
                  initialDate: startDate ?? DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    endDate = picked;
                  });
                }
              },
            ),

            Text('Total: Rp $total'),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () async {
                  if (startDate == null || endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pilih tanggal terlebih dahulu'),
                      ),
                    );
                    return;
                  }
                  final user = FirebaseAuth.instance.currentUser;

                  if (user == null) return;
                  final isAvailable = await ref
                      .read(rentalRepositoryProvider)
                      .isProductAvailable(
                        productId: widget.product.id,
                        startDate: startDate!,
                        endDate: endDate!,
                        stock: widget.product.stock,
                      );

                  if (!isAvailable) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Produk tidak tersedia pada tanggal tersebut',
                          ),
                        ),
                      );
                    }

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

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Penyewaan berhasil dibuat'),
                      ),
                    );

                    Navigator.pop(context);
                  }
                },
                child: const Text('Konfirmasi Sewa'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
