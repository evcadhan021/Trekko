import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/product_model.dart';

class ProductRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<ProductModel>> getProducts() async {
    final snapshot = await firestore.collection('products').get();

    return snapshot.docs.map((doc) {
      return ProductModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<List<ProductModel>> getBestSellerProducts() async {
    final snapshot = await firestore
        .collection('products')
        .where('isBestSeller', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      return ProductModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<int> getUnavailableStock(String productId) async {
    final snapshot = await firestore
        .collection('rentals')
        .where('productId', isEqualTo: productId)
        .get();

    int rentedCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final status = data['status'].toString();

      if (status == 'pending' || status == 'confirmed' || status == 'active') {
        rentedCount++;
      }
    }

    return rentedCount;
  }

  // menambahkan produk baru ke database //
  Future<void> addProduct({
    required String name,
    required String category,
    required String description,
    required String imageUrl,
    required int pricePerDay,
    required int stock,
  }) async {
    await firestore.collection('products').add({
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'pricePerDay': pricePerDay,
      'stock': stock,
      'isBestSeller': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update produk yang sudah ada di database //
  Future<void> updateProduct({
    required String productId,
    required String name,
    required String category,
    required String description,
    required String imageUrl,
    required int pricePerDay,
    required int stock,
  }) async {
    await firestore.collection('products').doc(productId).update({
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'pricePerDay': pricePerDay,
      'stock': stock,
    });
  }

  // Hapus produk dari database //
  Future<void> deleteProduct(String productId) async {
    await firestore.collection('products').doc(productId).delete();
  }
}
