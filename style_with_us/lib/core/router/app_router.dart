import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

// --- ALL PROJECT SCREENS ---
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/ai/ai_analysis_screen.dart';
import '../../features/ai/results_screen.dart';
import '../../features/ai/virtual_tryon_screen.dart';
import '../../features/ar/ar_tryon_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/brands/brands_screen.dart';
import '../../features/brands/brand_dashboard_screen.dart';
import '../../features/brands/brand_products_screen.dart';
import '../../features/brands/photo_gallery_screen.dart';
import '../../features/brands/upload_photo_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/checkout/order_success_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/notifications/notification_center_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/orders/order_history_screen.dart';
import '../../features/profile/profile_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/login', // Defaults to login safely
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthScreen(),
    ),

    // --- ADMIN SHELL ROUTE ---
    ShellRoute(
      builder: (context, state, child) {
        return Consumer(
          builder: (context, ref, _) {
            final roleAsync = ref.watch(userRoleProvider);
            return roleAsync.when(
              data: (role) {
                if (role == null) return const AuthScreen(); // User is logged out
                if (role != 'admin') return const _UnauthorizedGuard();
                return _PopGuardLayout(fallbackPath: '/admin', child: child);
              },
              loading: () => const _PremiumLoadingScreen(),
              error: (e, s) => Scaffold(body: Center(child: Text('System Error: $e'))),
            );
          },
        );
      },
      routes: [
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
      ],
    ),

    // --- BRAND SHELL ROUTE ---
    ShellRoute(
      builder: (context, state, child) {
        return Consumer(
          builder: (context, ref, _) {
            final roleAsync = ref.watch(userRoleProvider);
            return roleAsync.when(
              data: (role) {
                if (role == null) return const AuthScreen();
                if (role != 'brand') return const _UnauthorizedGuard();
                return _PopGuardLayout(fallbackPath: '/brand', child: child);
              },
              loading: () => const _PremiumLoadingScreen(),
              error: (e, s) => Scaffold(body: Center(child: Text('System Error: $e'))),
            );
          },
        );
      },
      routes: [
        GoRoute(
          path: '/brand',
          builder: (context, state) => const BrandDashboardScreen(),
        ),
        GoRoute(
          path: '/brands/upload',
          builder: (context, state) => const BrandUploadScreen(),
        ),
      ],
    ),

    // --- USER SHELL ROUTE ---
    ShellRoute(
      builder: (context, state, child) {
        return Consumer(
          builder: (context, ref, _) {
            final roleAsync = ref.watch(userRoleProvider);
            return roleAsync.when(
              data: (role) {
                if (role == null) return const AuthScreen();
                // Allow all roles to access "User" screens (Home, Profile, etc.)
                // This prevents "Unauthorized Access" for brands navigating to profile/cart
                return _PopGuardLayout(
                  fallbackPath: role == 'admin' ? '/admin' : (role == 'brand' ? '/brand' : '/home'),
                  child: child,
                );
              },
              loading: () => const _PremiumLoadingScreen(),
              error: (e, s) => Scaffold(body: Center(child: Text('System Error: $e'))),
            );
          },
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/brands',
          builder: (context, state) => const BrandsScreen(),
        ),
        GoRoute(
          path: '/brands/gallery',
          builder: (context, state) => const PhotoGalleryScreen(),
        ),
        GoRoute(
          path: '/brands/:id',
          builder: (context, state) => BrandProductsScreen(
            brandId: state.pathParameters['id'] ?? '',
          ),
        ),
        GoRoute(
          path: '/ai-analysis',
          builder: (context, state) => const AIAnalysisScreen(),
        ),
        GoRoute(
          path: '/results/:analysisId',
          builder: (context, state) => ResultsScreen(
            analysisId: state.pathParameters['analysisId'] ?? '',
          ),
        ),
        GoRoute(
          path: '/virtual-try-on/:productId',
          builder: (context, state) => VirtualTryOnScreen(
            productId: state.pathParameters['productId'] ?? '',
          ),
        ),
        GoRoute(
          path: '/ar-tryon',
          builder: (context, state) => const ArTryOnScreen(),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/order-success/:orderId',
          builder: (context, state) => OrderSuccessScreen(
            orderId: state.pathParameters['orderId'] ?? '',
          ),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationCenterScreen(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const OrderHistoryScreen(),
        ),
      ],
    ),
  ],
);

// --- GUARDS & LAYOUTS ---

/// Safely handles the Android/System Back Button to prevent closing the app
class _PopGuardLayout extends StatelessWidget {
  final Widget child;
  final String fallbackPath;
  const _PopGuardLayout({required this.child, required this.fallbackPath});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Intercepts the back button
      onPopInvoked: (didPop) {
        if (didPop) return;
        
        // If there is history to pop, safely pop it.
        if (context.canPop()) {
          context.pop();
        } else {
          // If stack is completely empty, don't close the app.
          // Securely route them back to their role's main dashboard.
          context.go(fallbackPath);
        }
      },
      child: child,
    );
  }
}

class _UnauthorizedGuard extends StatelessWidget {
  const _UnauthorizedGuard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            const Text('Unauthorized Access', style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
              onPressed: () => context.go('/login'),
              child: const Text('Return to Login', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

class _PremiumLoadingScreen extends StatelessWidget {
  const _PremiumLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F172A), // Luxury Dark Theme
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)), // Indigo loading
      ),
    );
  }
}
