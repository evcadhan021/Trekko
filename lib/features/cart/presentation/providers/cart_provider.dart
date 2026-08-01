import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository();
});

final userCartProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return [];
  }

  return ref.read(cartRepositoryProvider).getUserCart(user.uid);
});
