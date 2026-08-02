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

  Future<void> removeFromCart(String cartId) async {
    await firestore.collection('cart').doc(cartId).delete();
  }

  Future<void> checkoutSelectedItems(
    List<String> selectedIds,
    String userId,
  ) async {
    final batch = firestore.batch();

    for (final cartId in selectedIds) {
      final cartDoc = await firestore.collection('cart').doc(cartId).get();

      if (!cartDoc.exists) continue;

      final data = cartDoc.data()!;

      final rentalRef = firestore.collection('rentals').doc();

      batch.set(rentalRef, {
        'userId': userId,
        'productId': data['productId'],
        'productName': data['productName'],
        'pricePerDay': data['pricePerDay'],

        'totalDays': 1,

        'totalPrice': data['pricePerDay'],

        'status': 'pending',

        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.delete(cartDoc.reference);
    }

    await batch.commit();
  }
}
