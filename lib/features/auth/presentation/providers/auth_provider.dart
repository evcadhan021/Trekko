import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trekko/features/auth/data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

// Provider Profile User //
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;

  if (user == null) {
    return null;
  }

  return ref.read(authRepositoryProvider).getUserProfile(user.uid);
});

// Role User Provider //
final userRoleProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;

  if (user == null) {
    return null;
  }

  final profile = await ref
      .read(authRepositoryProvider)
      .getUserProfile(user.uid);
  if (profile == null) return null;
  return profile['role'] as String?;
});
