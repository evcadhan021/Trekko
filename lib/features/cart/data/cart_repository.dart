import 'package:cloud_firestore/cloud_firestore.dart';

class CartRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addToCart({
    required String userId,
    required String productId,
    required String productName,
    required String imageUrl,
    required int pricePerDay,
  }) async {
    await firestore.collection('cart').add({
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'pricePerDay': pricePerDay,
      'quantity': 1,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getUserCart(String userId) async {
    final snapshot = await firestore
        .collection('cart')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();
  }
}
