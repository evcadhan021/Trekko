import 'package:go_router/go_router.dart';
import 'package:trekko/features/admin/presentation/pages/admin_notification_page.dart';

import '../../features/admin/presentation/pages/admin_dashboard_page.dart';

import '../features/splash/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/providers/auth_guard.dart';
import '../core/navigation/main_navigation_page.dart';
import '../features/admin/presentation/pages/admin_products_page.dart';
import '../features/cart/presentation/pages/cart_page.dart';

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
      builder: (context, state) => const AdminDashboardPage(),
    ),

    GoRoute(
      path: '/admin-products',
      builder: (context, state) => const AdminProductsPage(),
    ),

    GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
    GoRoute(
      path: '/admin-notifications',
      builder: (context, state) => const AdminNotificationsPage(),
    ),
  ],
);
