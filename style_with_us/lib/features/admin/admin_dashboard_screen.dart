import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF14B8A6),
          surface: Color(0xFF1E293B),
          onSurface: Color(0xFFF8FAFC),
          onSurfaceVariant: Color(0xFF94A3B8),
        ),
      ),
      child: const _AdminDashboardContent(),
    );
  }
}

class _AdminDashboardContent extends StatelessWidget {
  const _AdminDashboardContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          drawer: isMobile ? const Drawer(child: SideNavigationDrawer()) : null,
          appBar: isMobile
              ? AppBar(
                  backgroundColor: const Color(0xFF0F172A),
                  elevation: 0,
                  title: const Text('Admin Portal'),
                )
              : null,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navigation Sidebar for desktop
              if (!isMobile) const SideNavigationDrawer().animate().slideX(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOut),
              
              // Main Content Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Bar / Title
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Control Center',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),
                    ),
                    
                    // Main Scrollable Area
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatsGrid(context, constraints.maxWidth),
                            const SizedBox(height: 32),
                            _buildPerformanceSection(context),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(BuildContext context, double width) {
    int crossAxisCount = 4;
    if (width < 600) {
      crossAxisCount = 1;
    } else if (width < 1200) {
      crossAxisCount = 2;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: width < 600 ? 2.5 : 1.8,
      children: [
        _buildStatCard(
          context,
          title: 'Daily Engagement',
          value: '48.2k',
          percentage: '+12.5%',
          icon: Icons.trending_up,
          delay: 0,
        ),
        _buildStatCard(
          context,
          title: 'Active Brands',
          value: '1,204',
          percentage: '+3.1%',
          icon: Icons.group,
          delay: 100,
        ),
        _buildStatCard(
          context,
          title: 'AI Stylist Usage',
          value: '8.9k',
          percentage: '+45%',
          icon: Icons.auto_awesome,
          delay: 200,
        ),
        _buildStatCard(
          context,
          title: 'Net Revenue',
          value: '\$241k',
          percentage: '+8.2%',
          icon: Icons.payments,
          delay: 300,
        ),
      ],
    );
  }

  Widget _buildPerformanceSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Performance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          _buildSystemMetric(context, 'API Response Time', '120ms', 0.2),
          const SizedBox(height: 16),
          _buildSystemMetric(context, 'CPU Utilization', '42%', 0.42),
          const SizedBox(height: 16),
          _buildSystemMetric(context, 'Database Load', '28%', 0.28),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildSystemMetric(BuildContext context, String label, String value, double progress) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14)),
            Text(value, style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xFF334155),
          color: colors.primary,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ).animate().custom(duration: 800.ms, builder: (context, val, child) => LinearProgressIndicator(
          value: val * progress,
          backgroundColor: const Color(0xFF334155),
          color: colors.primary,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        )),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String percentage,
    required IconData icon,
    required int delay,
  }) {
    final colors = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
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
                child: Icon(icon, color: colors.primary, size: 24),
              ),
              Text(
                percentage,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

class SideNavigationDrawer extends StatelessWidget {
  const SideNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return Container(
      width: 288, 
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.diamond_outlined,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Portal',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      'Brand Manager',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: const [
                NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isActive: true,
                ),
                NavItem(
                  icon: Icons.analytics_outlined,
                  label: 'Analytics',
                  isActive: false,
                ),
                NavItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Inventory',
                  isActive: false,
                ),
                NavItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Orders',
                  isActive: false,
                ),
              ],
            ),
          ),

          // Bottom Settings & Profile
          const NavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isActive: false,
          ),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF334155)),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF334155),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alex Rivera',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ACTIVE',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? colors.primary : Colors.transparent,
          border: isActive
              ? Border(right: BorderSide(color: colors.primary, width: 4))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF0F172A) : colors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive ? const Color(0xFF0F172A) : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

