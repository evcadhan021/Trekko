import 'package:cloud_firestore/cloud_firestore.dart';

class RentalRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // buat data rental baru //

  Future<void> createRental({
    required String userId,
    required String userName,
    required String productId,
    required String productName,

    required DateTime startDate,
    required DateTime endDate,

    required int totalDays,
    required int pricePerDay,
  }) async {
    final totalPrice = totalDays * pricePerDay;

    await firestore.collection('rentals').add({
      'userId': userId,
      'userName': userName,

      'productId': productId,
      'productName': productName,

      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),

      'totalDays': totalDays,
      'pricePerDay': pricePerDay,
      'totalPrice': totalPrice,

      'status': 'pending',

      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Ambil data rental //

  Future<List<Map<String, dynamic>>> getUserRentals(String userId) async {
    final snapshot = await firestore
        .collection('rentals')
        .where('userId', isEqualTo: userId)
        .get();

    final items = snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();

    return items.where((item) {
      final status = item['status'].toString();

      return status == 'pending' || status == 'confirmed' || status == 'active';
    }).toList();
  }

  // Ambil data riwayat rental //

  Future<List<Map<String, dynamic>>> getRentalHistory(String userId) async {
    final snapshot = await firestore
        .collection('rentals')
        .where('userId', isEqualTo: userId)
        .get();

    final items = snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();

    return items.where((item) {
      final status = item['status'].toString();

      return status == 'cancelled' ||
          status == 'cancelled_by_admin' ||
          status == 'completed';
    }).toList();
  }

  // Membatalkan rental //

  Future<void> cancelRental(String rentalId) async {
    await firestore.collection('rentals').doc(rentalId).update({
      'status': 'cancelled',
    });
  }

  Future<bool> isProductAvailable({
    required String productId,
    required DateTime startDate,
    required DateTime endDate,
    required int stock,
  }) async {
    final snapshot = await firestore
        .collection('rentals')
        .where('productId', isEqualTo: productId)
        .get();

    int conflictCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final status = data['status'];

      if (status != 'pending' && status != 'confirmed' && status != 'active') {
        continue;
      }

      final existingStart = (data['startDate'] as Timestamp).toDate();

      final existingEnd = (data['endDate'] as Timestamp).toDate();

      final isConflict =
          startDate.isBefore(existingEnd) && endDate.isAfter(existingStart);

      if (isConflict) {
        conflictCount++;
      }
    }

    return conflictCount < stock;
  }
}
