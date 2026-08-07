import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/admin_constants.dart';

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
    DateTime startDate, // <-- Tambahan parameter tanggal sewa
    DateTime endDate, // <-- Tambahan parameter tanggal kembali
  ) async {
    // 1. Hitung total hari otomatis dari selisih tanggal sewa dan kembali
    final totalDays = endDate.difference(startDate).inDays;
    final calculatedDays = totalDays <= 0 ? 1 : totalDays;

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

        // 2. Masukkan hasil perhitungan & tanggal ke Firestore
        'totalDays': calculatedDays,
        'totalPrice': data['pricePerDay'] * calculatedDays,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),

        'status': 'pending',

        'createdAt': FieldValue.serverTimestamp(),
      });
      final notificationRef = firestore.collection('notifications').doc();

      batch.set(notificationRef, {
        'userId': AdminConstants.adminUid,

        'title': 'Rental Baru',

        'message': '${data['productName']} disewa oleh user.',

        'isRead': false,

        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.delete(cartDoc.reference);
    }

    await batch.commit();
  }
}
