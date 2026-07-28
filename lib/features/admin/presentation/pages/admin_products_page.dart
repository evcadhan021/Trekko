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
          return ListView.builder(
            itemCount: items.length,

            itemBuilder: (context, index) {
              final product = items[index];

              return Card(
                margin: const EdgeInsets.all(8),

                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProductPage(product: product),
                      ),
                    );
                  },
                  leading: Image.network(
                    product.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),

                  title: Text(product.name),

                  subtitle: Text('Rp ${product.pricePerDay}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),

                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,

                        builder: (_) {
                          return AlertDialog(
                            title: const Text('Hapus Produk'),

                            content: Text(
                              'Yakin ingin menghapus ${product.name} ?',
                            ),

                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text('Batal'),
                              ),

                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
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
                ),
              );
            },
          );
        },

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, s) => Center(child: Text(e.toString())),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}
