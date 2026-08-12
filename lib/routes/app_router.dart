import 'package:go_router/go_router.dart';
import 'package:trekko/features/admin/presentation/pages/admin_notification_page.dart';
import 'package:trekko/features/chat/presentation/pages/admin_chat_detail_page.dart';
import 'package:trekko/features/chat/presentation/pages/admin_chat_list_page.dart';
import 'package:trekko/features/notification/presentation/pages/user_notifications_page.dart';

import '../core/pages/access_denied_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';

import '../features/splash/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/providers/auth_guard.dart';
import '../core/navigation/main_navigation_page.dart';
import '../features/admin/presentation/pages/admin_products_page.dart';
import '../features/cart/presentation/pages/cart_page.dart';
import '../features/product/presentation/pages/all_products_page.dart';
import '../features/home/presentation/pages/hiking_guide_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/access-denied',
      builder: (context, state) => const AccessDeniedPage(),
    ),
    GoRoute(
      path: '/home',
      redirect: (context, state) {
        if (!AuthGuard.isLoggedIn()) {
          return '/login';
        }
        return null;
      },
      builder: (context, state) => const MainNavigationPage(),
    ),
    GoRoute(
      path: '/admin',
      redirect: (context, state) async {
        if (!AuthGuard.isLoggedIn()) return '/login';
        if (!await AuthGuard.isAdmin()) return '/access-denied';
        return null;
      },
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: '/admin-products',
      redirect: (context, state) async {
        if (!AuthGuard.isLoggedIn()) return '/login';
        if (!await AuthGuard.isAdmin()) return '/access-denied';
        return null;
      },
      builder: (context, state) => const AdminProductsPage(),
    ),
    GoRoute(
      path: '/cart',
      redirect: (context, state) {
        if (!AuthGuard.isLoggedIn()) {
          return '/login';
        }
        return null;
      },
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: '/admin-notifications',
      redirect: (context, state) async {
        if (!AuthGuard.isLoggedIn()) return '/login';
        if (!await AuthGuard.isAdmin()) return '/access-denied';
        return null;
      },
      builder: (context, state) => const AdminNotificationsPage(),
    ),
    GoRoute(
      path: '/notifications',
      redirect: (context, state) {
        if (!AuthGuard.isLoggedIn()) {
          return '/login';
        }
        return null;
      },
      builder: (context, state) => const UserNotificationsPage(),
    ),
    GoRoute(
      path: '/all-products',
      redirect: (context, state) {
        if (!AuthGuard.isLoggedIn()) {
          return '/login';
        }
        return null;
      },
      builder: (context, state) => const AllProductsPage(),
    ),
    GoRoute(
      path: '/hiking-guide',
      redirect: (context, state) {
        if (!AuthGuard.isLoggedIn()) {
          return '/login';
        }
        return null;
      },
      builder: (context, state) => const HikingGuidePage(),
    ),
    GoRoute(
      path: '/admin-chat-list',
      redirect: (context, state) async {
        if (!AuthGuard.isLoggedIn()) return '/login';
        if (!await AuthGuard.isAdmin()) return '/access-denied';
        return null;
      },
      builder: (context, state) => const AdminChatListPage(),
    ),
    GoRoute(
      path: '/admin-chat-detail',
      redirect: (context, state) async {
        if (!AuthGuard.isLoggedIn()) return '/login';
        if (!await AuthGuard.isAdmin()) return '/access-denied';
        return null;
      },
      builder: (context, state) {
        final userId = state.extra as String? ?? '';
        return AdminChatDetailPage(userId: userId);
      },
    ),
  ],
);
