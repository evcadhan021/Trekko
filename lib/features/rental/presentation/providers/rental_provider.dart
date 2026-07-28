import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/rental_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

final rentalRepositoryProvider = Provider<RentalRepository>((ref) {
  return RentalRepository();
});

final userRentalsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return [];
  }

  return ref.read(rentalRepositoryProvider).getUserRentals(user.uid);
});

final rentalHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return [];
  }

  return ref.read(rentalRepositoryProvider).getRentalHistory(user.uid);
});
