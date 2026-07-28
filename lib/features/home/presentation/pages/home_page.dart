import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/presentation/providers/category_provider.dart';
import '../../../product/presentation/providers/product_provider.dart';
import '../../../product/presentation/pages/product_detail_page.dart';
import '../../../product/presentation/providers/search_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final categories = [
      'Semua',
      'Carrier',
      'Tenda',
      'Kompor',
      'Sepatu',
      'Sleeping Bag',
    ];
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final bestSellerProducts = ref.watch(bestSellerProductsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('TREKKO')),

      body: products.when(
        data: (items) {
          final filteredProducts = items.where((product) {
            final categoryMatch = selectedCategory == 'Semua'
                ? true
                : product.category == selectedCategory;

            final searchMatch = product.name.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );

            return categoryMatch && searchMatch;
          }).toList();

          return Column(
            children: [
              // Search Bar //
              Padding(
                padding: const EdgeInsets.all(12),

                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari perlengkapan...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                ),
              ),

              // Produk Terlaris //
              bestSellerProducts.when(
                data: (bestItems) {
                  return SizedBox(
                    height: 180,

                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,

                      itemCount: bestItems.length,

                      itemBuilder: (context, index) {
                        final product = bestItems[index];

                        return Container(
                          width: 200,
                          margin: const EdgeInsets.all(8),

                          child: Card(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.network(
                                    product.imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(8),

                                  child: Text(product.name, maxLines: 1),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },

                loading: () => const CircularProgressIndicator(),

                error: (e, s) => const SizedBox(),
              ),

              // KATEGORI DI SINI //
              SizedBox(
                height: 60,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,

                  itemCount: categories.length,

                  itemBuilder: (context, index) {
                    final category = categories[index];

                    final isSelected = selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 10,
                      ),

                      child: ChoiceChip(
                        label: Text(category),

                        selected: isSelected,

                        onSelected: (_) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              category;
                        },
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredProducts.length,

                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(product.imageUrl),
                      ),

                      title: Text(product.name),

                      subtitle: Text('Rp ${product.pricePerDay}/hari'),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(product: product),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },

        error: (error, stack) {
          return Center(child: Text(error.toString()));
        },

        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
