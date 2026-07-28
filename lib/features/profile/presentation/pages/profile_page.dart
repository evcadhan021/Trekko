import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../rental/presentation/providers/rental_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final role = ref.watch(userRoleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),

      body: profile.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User tidak ditemukan'));
          }

          return Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),

                const SizedBox(height: 20),

                Text('Nama', style: TextStyle(color: Colors.grey)),

                Text(
                  user['name'] ?? '-',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Text('Email', style: TextStyle(color: Colors.grey)),

                Text(
                  user['email'] ?? '-',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),

                const Text('Role'),

                role.when(
                  data: (value) => Text(value ?? '-'),

                  loading: () => const CircularProgressIndicator(),

                  error: (e, s) => const Text('Error'),
                ),
                role.when(
                  data: (value) {
                    if (value != 'admin') {
                      return const SizedBox();
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/admin');
                        },
                        child: const Text('Dashboard Admin'),
                      ),
                    );
                  },

                  loading: () => const SizedBox(),

                  error: (_, __) => const SizedBox(),
                ),

                const SizedBox(height: 16),
                const Spacer(),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(authRepositoryProvider).logout();
                        ref.invalidate(userProfileProvider);
                        ref.invalidate(userRoleProvider);
                        ref.invalidate(userRentalsProvider);
                        ref.invalidate(rentalHistoryProvider);

                        if (context.mounted) {
                          context.go('/login');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal logout: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, s) => Center(child: Text(e.toString())),
      ),
    );
  }
}
