import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../rental/presentation/pages/create_rantel_page.dart';
import '../../domain/product_model.dart';
import '../../presentation/providers/product_provider.dart';

class ProductDetailPage extends ConsumerWidget {
  final ProductModel product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rentedAsync = ref.watch(unavailableStockProvider(product.id));

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            SizedBox(
              width: double.infinity,
              height: 250,

              child: Image.network(product.imageUrl, fit: BoxFit.cover),
            ),

            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Chip(label: Text(product.category)),

                  const SizedBox(height: 16),

                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Harga Sewa',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  Text(
                    'Rp ${product.pricePerDay} / hari',
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Stok Tersedia',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  rentedAsync.when(
                    data: (rented) {
                      final available = product.stock - rented;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Stok : ${product.stock}'),

                          Text('Sedang Disewa : $rented'),

                          Text('Tersedia : $available'),
                        ],
                      );
                    },

                    loading: () => const CircularProgressIndicator(),

                    error: (_, __) => const Text('Gagal memuat stok'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),

        child: SizedBox(
          height: 50,

          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateRentalPage(product: product),
                ),
              );
            },

            child: const Text('Sewa Sekarang'),
          ),
        ),
      ),
    );
  }
}
