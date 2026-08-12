import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trekko/features/admin/presentation/pages/add_product_page.dart';
import 'package:trekko/features/admin/presentation/pages/edit_product_page.dart';

import '../../../product/presentation/providers/product_provider.dart';

class AdminProductsPage extends ConsumerWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Produk')),
      body: products.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada produk untuk dikelola'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
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
                            'Produk Tersedia',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${items.length} item',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddProductPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Tambah'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...items.map((product) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
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
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          product.imageUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 72,
                            height: 72,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditProductPage(product: product),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.category,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Rp ${product.pricePerDay} / hari',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () async {
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: const Text('Hapus Produk'),
                                content: Text(
                                  'Yakin ingin menghapus ${product.name}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (result != true) return;

                          await ref
                              .read(productRepositoryProvider)
                              .deleteProduct(product.id);
                          ref.invalidate(productsProvider);
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(e.toString())),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Produk'),
      ),
    );
  }
}
