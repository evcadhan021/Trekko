import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/admin_constants.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/chat/data/chat_repository.dart';
import '../../features/chat/presentation/pages/user_admin_chat_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/rental/presentation/pages/rental_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class MainNavigationPage extends ConsumerStatefulWidget {
  const MainNavigationPage({super.key});

  @override
  ConsumerState<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends ConsumerState<MainNavigationPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userRole = ref.watch(userRoleProvider);
    final isUser = userRole.valueOrNull?.toLowerCase() == 'user';

    final pages = [
      const HomePage(),
      const RentalPage(),
      const HistoryPage(),
      if (isUser) const UserAdminChatPage(),
      const ProfilePage(),
    ];

    final safeIndex = currentIndex >= pages.length
        ? pages.length - 1
        : currentIndex;
    if (currentIndex != safeIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            currentIndex = safeIndex;
          });
        }
      });
    }

    return Scaffold(
      body: pages[safeIndex],
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 14,
          right: 14,
          bottom: MediaQuery.of(context).padding.bottom + 8,
          top: 8,
        ),
        child: SafeArea(
          top: false,
          child: Container(
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E9E5A),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    23,
                    117,
                    67,
                  ).withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                navigationBarTheme: NavigationBarThemeData(
                  backgroundColor: const Color(0xFF1E9E5A),
                  surfaceTintColor: Colors.transparent,
                  indicatorColor: Colors.white.withValues(alpha: 0.18),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    return const IconThemeData(color: Colors.white);
                  }),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    return const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    );
                  }),
                ),
              ),
              child: NavigationBar(
                height: 72,
                elevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                indicatorColor: Colors.white.withValues(alpha: 0.18),
                selectedIndex: safeIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.home_outlined, color: Colors.white),
                    selectedIcon: Icon(Icons.home_rounded, color: Colors.white),
                    label: 'Home',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.backpack_outlined, color: Colors.white),
                    selectedIcon: Icon(
                      Icons.backpack_rounded,
                      color: Colors.white,
                    ),
                    label: 'Rental',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.history_outlined, color: Colors.white),
                    selectedIcon: Icon(
                      Icons.history_rounded,
                      color: Colors.white,
                    ),
                    label: 'Riwayat',
                  ),
                  if (isUser)
                    NavigationDestination(
                      icon: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: currentUser == null
                            ? Stream.value(const [])
                            : ChatRepository().getMessagesStream(
                                currentUser.uid,
                              ),
                        builder: (context, snapshot) {
                          final unreadCount = (snapshot.data ?? [])
                              .where(
                                (message) =>
                                    message['senderId'] ==
                                        AdminConstants.adminUid &&
                                    !(message['isRead'] as bool? ?? false),
                              )
                              .length;

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: Colors.white,
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      unreadCount > 99
                                          ? '99+'
                                          : unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      selectedIcon: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: currentUser == null
                            ? Stream.value(const [])
                            : ChatRepository().getMessagesStream(
                                currentUser.uid,
                              ),
                        builder: (context, snapshot) {
                          final unreadCount = (snapshot.data ?? [])
                              .where(
                                (message) =>
                                    message['senderId'] ==
                                        AdminConstants.adminUid &&
                                    !(message['isRead'] as bool? ?? false),
                              )
                              .length;

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.chat_bubble_rounded,
                                color: Colors.white,
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      unreadCount > 99
                                          ? '99+'
                                          : unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      label: 'Chat',
                    ),
                  const NavigationDestination(
                    icon: Icon(Icons.person_outline, color: Colors.white),
                    selectedIcon: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                    ),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
