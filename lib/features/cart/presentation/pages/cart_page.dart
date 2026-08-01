import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
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

          return ListView.builder(
            itemCount: items.length,

            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                margin: const EdgeInsets.all(8),

                child: ListTile(
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),

                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text('Hapus Produk?'),

                            content: const Text(
                              'Produk akan dihapus dari keranjang.',
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

                      if (confirm != true) {
                        return;
                      }

                      await ref
                          .read(cartRepositoryProvider)
                          .removeFromCart(item['id']);

                      ref.invalidate(userCartProvider);
                    },
                  ),
                  leading: Image.network(
                    item['imageUrl'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),

                  title: Text(item['productName']),

                  subtitle: Text('Rp ${item['pricePerDay']} / hari'),
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
