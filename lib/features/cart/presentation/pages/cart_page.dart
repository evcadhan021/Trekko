import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
