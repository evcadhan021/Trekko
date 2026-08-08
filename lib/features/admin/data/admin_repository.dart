import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trekko/features/notification/data/notification_repository.dart';

class AdminRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final NotificationRepository notificationRepository =
      NotificationRepository();

  Future<List<Map<String, dynamic>>> getAllRentals() async {
    final snapshot = await firestore
        .collection('rentals')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();
  }

  // Method to update the status of a rental and notify the user
  Future<void> updateRentalStatus({
    required String rentalId,
    required String status,
  }) async {
    final rentalDoc = await firestore.collection('rentals').doc(rentalId).get();

    if (!rentalDoc.exists) {
      return;
    }

    final rentalData = rentalDoc.data() as Map<String, dynamic>;
    final currentStatus = rentalData['status']?.toString() ?? '';
    final userId = rentalData['userId']?.toString();
    final productName = rentalData['productName']?.toString() ?? 'Produk';

    if (currentStatus == status) {
      return;
    }

    await firestore.collection('rentals').doc(rentalId).update({
      'status': status,
    });

    if (userId != null && userId.isNotEmpty) {
      final title = 'Status Rental Diperbarui';
      final message = _buildStatusMessage(status, productName);

      await notificationRepository.createNotification(
        userId: userId,
        title: title,
        message: message,
      );
    }
  }

  String _buildStatusMessage(String status, String productName) {
    switch (status) {
      case 'confirmed':
        return 'Rental "$productName" telah dikonfirmasi oleh admin.';
      case 'active':
        return 'Rental "$productName" kini aktif.';
      case 'completed':
        return 'Rental "$productName" telah selesai.';
      case 'cancelled_by_admin':
      case 'cancelled':
        return 'Rental "$productName" dibatalkan oleh admin.';
      default:
        return 'Status rental "$productName" berubah menjadi $status.';
    }
  }
}
