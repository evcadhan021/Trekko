import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../rental/presentation/providers/rental_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _openEditProfileSheet(Map<String, dynamic> user) async {
    final nameController = TextEditingController(
      text: user['name']?.toString() ?? '',
    );
    final uid = (user['uid'] ?? FirebaseAuth.instance.currentUser?.uid ?? '')
        .toString();
    File? selectedFile;
    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickImageFromGallery() async {
              final pickedFile = await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );

              if (pickedFile == null) return;
              setSheetState(() => selectedFile = File(pickedFile.path));
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Edit Profil',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: pickImageFromGallery,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 52,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: selectedFile != null
                                  ? FileImage(selectedFile!)
                                  : (user['photoUrl']?.toString() != null &&
                                        user['photoUrl'].toString().isNotEmpty)
                                  ? CachedNetworkImageProvider(
                                      user['photoUrl'].toString(),
                                    )
                                  : null,
                              child:
                                  selectedFile == null &&
                                      (user['photoUrl'] == null ||
                                          user['photoUrl'].toString().isEmpty)
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 44,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final navigator = Navigator.of(sheetContext);
                          final messenger = ScaffoldMessenger.maybeOf(
                            sheetContext,
                          );

                          try {
                            String? photoUrl = user['photoUrl']?.toString();

                            if (selectedFile != null) {
                              photoUrl = await ref
                                  .read(authRepositoryProvider)
                                  .uploadProfileImage(
                                    uid: uid,
                                    file: selectedFile!,
                                  );
                            }

                            await ref
                                .read(authRepositoryProvider)
                                .updateUserProfile(
                                  uid: uid,
                                  name: nameController.text,
                                  photoUrl: photoUrl,
                                );

                            ref.invalidate(userProfileProvider);
                            if (navigator.mounted) {
                              navigator.pop(true);
                            }
                            if (messenger != null) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Profil berhasil diperbarui'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (messenger != null) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menyimpan profil: $e'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Simpan Perubahan'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result == true) {
      ref.invalidate(userProfileProvider);
    }
  }

  Future<void> handleLogout() async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Keluar akun?'),
        content: const Text('Anda yakin ingin logout dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      await ref.read(authRepositoryProvider).logout();
      ref.invalidate(authStateProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(userRoleProvider);
      ref.invalidate(userRentalsProvider);
      ref.invalidate(rentalHistoryProvider);

      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (messenger != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Gagal logout: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final role = ref.watch(userRoleProvider);
    final notifications = ref.watch(userNotificationsProvider);
    final isDarkMode = ref.watch(appThemeModeProvider) == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: profile.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User tidak ditemukan'));
          }

          final name = user['name']?.toString() ?? 'Pengguna';
          final email = user['email']?.toString() ?? '-';
          final photoUrl = user['photoUrl']?.toString();
          final isAdmin = (role.value ?? '').toLowerCase() == 'admin';
          final unreadCount = notifications.maybeWhen(
            data: (items) => items
                .where((item) => !(item['isRead'] as bool? ?? false))
                .length,
            orElse: () => 0,
          );

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.18),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.18,
                              ),
                              backgroundImage:
                                  photoUrl != null && photoUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(photoUrl)
                                  : null,
                              child: photoUrl == null || photoUrl.isEmpty
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 34,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isAdmin
                                    ? Icons.shield_rounded
                                    : Icons.person_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isAdmin ? 'Admin' : 'User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _infoMiniCard(
                          context,
                          icon: Icons.workspace_premium_rounded,
                          label: 'Status',
                          value: isAdmin ? 'Admin' : 'Akun user',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoMiniCard(
                          context,
                          icon: Icons.lock_outline_rounded,
                          label: 'Akses',
                          value: isAdmin ? 'Full' : 'Terbatas',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (!isAdmin)
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/notifications'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.notifications_active_rounded,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Notifikasi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    unreadCount > 0
                                        ? '$unreadCount belum dibaca'
                                        : 'Semua notifikasi sudah dibaca',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  unreadCount > 99
                                      ? '99+'
                                      : unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              )
                            else
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey,
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  if (!isAdmin)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _openEditProfileSheet(user),
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Edit Profil'),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.badge_outlined),
                            title: const Text('Nama Lengkap'),
                            subtitle: Text(name),
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.email_outlined),
                            title: const Text('Email'),
                            subtitle: Text(email),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  role.when(
                    data: (value) {
                      if (value?.toLowerCase() != 'admin') {
                        return const SizedBox();
                      }

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/admin'),
                          icon: const Icon(Icons.dashboard_customize_rounded),
                          label: const Text('Dashboard Admin'),
                        ),
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: SwitchListTile.adaptive(
                      value: isDarkMode,
                      onChanged: (value) {
                        ref.read(appThemeModeProvider.notifier).toggle(value);
                      },
                      title: const Text('Dark mode'),
                      subtitle: const Text(
                        'Aktifkan tampilan gelap untuk semua layar',
                      ),
                      secondary: const Icon(Icons.dark_mode_rounded),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: handleLogout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.redAccent),
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _infoMiniCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
