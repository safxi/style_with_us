import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          surface: Color(0xFF1E293B),
          onSurface: Color(0xFFF8FAFC),
          onSurfaceVariant: Color(0xFF94A3B8),
          outline: Color(0xFF334155),
        ),
      ),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends ConsumerWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final roleAsync = ref.watch(userRoleProvider);
    final role = roleAsync.when(
      data: (value) => value,
      loading: () => null,
      error: (_, __) => null,
    );

    return Scaffold(
      appBar: _buildAppBar(colors),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colors).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
              const SizedBox(height: 32),
              _buildAIBentoCards(context, colors).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 32),
              _buildTrendingSection(colors).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 32),
              _buildHubSection(colors).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, colors, role).animate().slideY(
            begin: 1.0,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOut,
          ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colors) {
    return AppBar(
      backgroundColor: const Color(0xFF0F172A).withOpacity(0.95),
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 24.0, top: 8.0, bottom: 8.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.outline),
          ),
          child: const CircleAvatar(
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
            ),
          ),
        ),
      ),
      title: Text(
        'Style With Us',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colors.primary,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: colors.primary),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: colors.outline,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME BACK',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
              height: 1.2,
              letterSpacing: -0.5,
            ),
            children: [
              const TextSpan(text: 'Curating your '),
              TextSpan(
                text: 'Evening\nGala',
                style: TextStyle(color: colors.primary),
              ),
              const TextSpan(text: ' look.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIBentoCards(BuildContext context, ColorScheme colors) {
    return LayoutBuilder(
      builder: (layoutContext, constraints) {
        final isWide = constraints.maxWidth > 700;

        final mainCard = GestureDetector(
          onTap: () => context.push('/ai-analysis'),
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: 0.2,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.15),
                          border: Border.all(color: colors.primary),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, color: colors.primary, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'AI STYLIST ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Analyze My Wardrobe',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generate 5 new outfits from your collection using AI vision.',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 24,
                  right: 24,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );

        final secondaryCard = GestureDetector(
          onTap: () => context.push('/ar-tryon'),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.view_in_ar, color: colors.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  'AR Try-on',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Instant visual fit check',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );

        if (isWide) {
          return Row(
            children: [
              Expanded(flex: 2, child: mainCard),
              const SizedBox(width: 16),
              Expanded(child: SizedBox(height: 220, child: secondaryCard)),
            ],
          );
        }

        return Column(
          children: [
            mainCard,
            const SizedBox(height: 16),
            secondaryCard,
          ],
        );
      },
    );
  }

  Widget _buildTrendingSection(ColorScheme colors) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Trending Now',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            Text(
              'View All',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildProductCard(
                colors: colors,
                brand: 'MAISON TECH-COUTURE',
                name: 'Sculpted Shell Bag',
                price: '\$2,450.00',
                imageUrl: 'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?auto=format&fit=crop&w=600&q=80',
                matchScore: '92%',
                progress: 0.92,
              ),
              const SizedBox(width: 16),
              _buildProductCard(
                colors: colors,
                brand: 'OBSIDIAN NOIR',
                name: 'Fluid Chrome Trench',
                price: '\$3,100.00',
                imageUrl: 'https://images.unsplash.com/photo-1618244972963-dbee1a7edc95?auto=format&fit=crop&w=600&q=80',
                matchScore: '88%',
                progress: 0.88,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard({
    required ColorScheme colors,
    required String brand,
    required String name,
    required String price,
    required String imageUrl,
    required String matchScore,
    required double progress,
  }) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 340,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          backgroundColor: colors.outline.withOpacity(0.5),
                          color: colors.primary,
                        ),
                        Center(
                          child: Text(
                            matchScore,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            brand,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildHubSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Hub',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildHubTile(
          colors,
          icon: Icons.history,
          title: 'Recent AI Results',
        ),
        const SizedBox(height: 12),
        _buildHubTile(
          colors,
          icon: Icons.bookmark_border,
          title: 'Saved Collections',
        ),
      ],
    );
  }

  Widget _buildHubTile(ColorScheme colors, {required IconData icon, required String title}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurface,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, ColorScheme colors, String? role) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(top: BorderSide(color: colors.outline)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurfaceVariant,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              if (role == 'admin') {
                context.go('/admin');
              } else if (role == 'brand') {
                context.go('/brand');
              } else {
                context.go('/home');
              }
              break;
            case 1:
              context.push('/ai-analysis');
              break;
            case 2:
              context.push('/cart');
              break;
            case 3:
              context.push('/profile');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(role == 'brand' || role == 'admin' ? Icons.dashboard_outlined : Icons.home_outlined),
            ),
            activeIcon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(role == 'brand' || role == 'admin' ? Icons.dashboard : Icons.home),
            ),
            label: role == 'brand' || role == 'admin' ? 'Dashboard' : 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.auto_awesome),
            ),
            label: 'AI Stylist',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.person_outline),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
