import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAllRentals() async {
    final snapshot = await firestore
        .collection('rentals')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  // Method to update the status of a rental
  Future<void> updateRentalStatus({
    required String rentalId,
    required String status,
  }) async {
    await firestore.collection('rentals').doc(rentalId).update({
      'status': status,
    });
  }
}
