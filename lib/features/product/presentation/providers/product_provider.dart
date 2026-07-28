import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/product_repository.dart';
import '../../domain/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final productsProvider = FutureProvider<List<ProductModel>>((ref) {
  return ref.read(productRepositoryProvider).getProducts();
});

final bestSellerProductsProvider = FutureProvider<List<ProductModel>>((ref) {
  return ref.read(productRepositoryProvider).getBestSellerProducts();
});

final unavailableStockProvider = FutureProvider.family<int, String>((
  ref,
  productId,
) async {
  return ref.read(productRepositoryProvider).getUnavailableStock(productId);
});
