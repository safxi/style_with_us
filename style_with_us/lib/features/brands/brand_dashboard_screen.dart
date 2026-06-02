import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class BrandDashboardScreen extends StatelessWidget {
  const BrandDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1),
          surface: Color(0xFF1E293B),
          onSurface: Color(0xFFF8FAFC),
          onSurfaceVariant: Color(0xFF94A3B8),
          outline: Color(0xFF334155),
        ),
      ),
      child: const _BrandDashboardContent(),
    );
  }
}

class _BrandDashboardContent extends StatelessWidget {
  const _BrandDashboardContent();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: _buildAppBar(colors),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colors).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
              const SizedBox(height: 24),
              _buildPremiumBanner(colors).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),
              _buildStatCards(colors).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 24),
              _buildLineChartCard(colors).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              const SizedBox(height: 24),
              _buildAIChartCard(colors).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              const SizedBox(height: 24),
              _buildInventoryCard(colors).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              const SizedBox(height: 24),
              _buildRecentActivityCard(colors).animate().fadeIn(delay: 600.ms, duration: 400.ms),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, colors).animate().slideY(begin: 1.0, end: 0, duration: 400.ms, curve: Curves.easeOut),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colors) {
    return AppBar(
      backgroundColor: const Color(0xFF0F172A).withOpacity(0.9),
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(Icons.menu, color: colors.primary),
        onPressed: () {},
      ),
      title: Text(
        'Style With Us',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CircleAvatar(
            radius: 16,
            backgroundImage: const NetworkImage(
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
            ),
            backgroundColor: colors.outline,
          ),
        ),
        IconButton(
          icon: Icon(Icons.settings_outlined, color: colors.onSurfaceVariant),
          onPressed: () {},
        ),
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
        Row(
          children: [
            Text(
              'Brand',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '/',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Performance\nOverview',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumBanner(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.stars, color: colors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PREMIUM ACCOUNT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Luxury Tier Status: Gold',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.verified_outlined, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }

  Widget _buildStatCards(ColorScheme colors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth > 600 ? 1.8 : 1.5,
          children: [
            _buildSingleStatCard(
              colors: colors,
              title: 'TRY-ONS TODAY',
              value: '1,482',
              percentage: '+12.5%',
              icon: Icons.edit_outlined,
              progress: 0.75,
            ),
            _buildSingleStatCard(
              colors: colors,
              title: 'TOTAL SALES',
              value: '\$42,910',
              percentage: '+8.2%',
              icon: Icons.shopping_bag_outlined,
              progress: 0.5,
            ),
            _buildSingleStatCard(
              colors: colors,
              title: 'AI RECOMMENDATION MATCH',
              value: '94%',
              percentage: '+24%',
              icon: Icons.auto_awesome,
              progress: 0.94,
            ),
            _buildSingleStatCard(
              colors: colors,
              title: 'ACTIVE SESSIONS',
              value: '312',
              percentage: '+4.1%',
              icon: Icons.group_outlined,
              progress: 0.33,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSingleStatCard({
    required ColorScheme colors,
    required String title,
    required String value,
    required String percentage,
    required IconData icon,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: colors.primary, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  percentage,
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 32,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colors.outline,
            color: colors.primary,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartCard(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Try-ons vs Sales',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time daily\nconversion metrics',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Try-\nons',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sales',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(
              painter: ChartPainter(
                primaryColor: colors.primary,
                gridColor: colors.outline,
              ),
            ),
          ).animate().shimmer(duration: 1500.ms, color: colors.primary.withOpacity(0.1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _ChartLabel('08:00'),
              _ChartLabel('12:00'),
              _ChartLabel('16:00'),
              _ChartLabel('20:00'),
              _ChartLabel('00:00'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIChartCard(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        children: [
          Text(
            'AI Match Accuracy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 0.88,
                  strokeWidth: 12,
                  backgroundColor: colors.outline,
                  color: colors.primary,
                ).animate().custom(duration: 1000.ms, builder: (context, val, child) => CircularProgressIndicator(
                  value: val * 0.88,
                  strokeWidth: 12,
                  backgroundColor: colors.outline,
                  color: colors.primary,
                )),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '88%',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      'PERFECT FIT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'The virtual stylist successfully\nmatched 1,240 items to user body\nshapes today with high satisfaction.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onSurface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'View Style Trends',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=800&q=80', // Futuristic placeholder
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.4),
                ),
                Positioned(
                  bottom: 16,
                  left: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Top Seller',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Cyber-Knit Collection',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INVENTORY STATUS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurfaceVariant,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Low Stock - 14 Units',
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.outline,
                    foregroundColor: colors.onSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Manage\nStock', textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          _buildActivityRow(
            colors,
            icon: Icons.person_add_outlined,
            title: 'New VIP Member Joined',
            time: '2 minutes ago',
          ),
          const SizedBox(height: 24),
          _buildActivityRow(
            colors,
            icon: Icons.payments_outlined,
            title: 'Bulk Order #4928 Processed',
            time: '15 minutes ago',
          ),
          const SizedBox(height: 24),
          _buildActivityRow(
            colors,
            icon: Icons.insights_outlined,
            title: 'Weekly Report Generated',
            time: '1 hour ago',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(ColorScheme colors,
      {required IconData icon,
      required String title,
      required String time}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
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
        currentIndex: 0, // Home selected
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/brand');
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
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_outlined)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.auto_awesome)),
            label: 'AI Stylist',
          ),
          BottomNavigationBarItem(
            icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.shopping_cart_outlined)),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ChartLabel extends StatelessWidget {
  final String text;
  const _ChartLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// Custom Painter to mimic the SVG chart from HTML
class ChartPainter extends CustomPainter {
  final Color primaryColor;
  final Color gridColor;

  ChartPainter({required this.primaryColor, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Background Grid
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, h * 0.25), Offset(w, h * 0.25), gridPaint);
    canvas.drawLine(Offset(0, h * 0.50), Offset(w, h * 0.50), gridPaint);
    canvas.drawLine(Offset(0, h * 0.75), Offset(w, h * 0.75), gridPaint);

    // Coordinate conversion based on SVG (ViewBox 0 0 400 100)
    double mapX(double x) => (x / 400.0) * w;
    double mapY(double y) => (y / 100.0) * h;

    final linePaint1 = Paint()
      ..color = primaryColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePaint2 = Paint()
      ..color = primaryColor.withOpacity(0.4)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Path 1 (Try-ons)
    final path1 = Path();
    path1.moveTo(mapX(0), mapY(80));
    path1.quadraticBezierTo(mapX(50), mapY(20), mapX(100), mapY(50));
    path1.quadraticBezierTo(mapX(150), mapY(80), mapX(200), mapY(30));
    path1.quadraticBezierTo(mapX(250), mapY(-20), mapX(300), mapY(60));
    path1.quadraticBezierTo(mapX(350), mapY(140), mapX(400), mapY(20));
    
    canvas.drawPath(path1, linePaint1);

    // Path 2 (Sales)
    final path2 = Path();
    path2.moveTo(mapX(0), mapY(90));
    path2.quadraticBezierTo(mapX(50), mapY(60), mapX(100), mapY(80));
    path2.quadraticBezierTo(mapX(150), mapY(100), mapX(200), mapY(60));
    path2.quadraticBezierTo(mapX(250), mapY(20), mapX(300), mapY(75));
    path2.quadraticBezierTo(mapX(350), mapY(130), mapX(400), mapY(40));

    canvas.drawPath(path2, linePaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

