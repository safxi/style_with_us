import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/style_tokens.dart';
import '../../core/widgets/style_bottom_nav_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  static const String routeName = 'profile';

  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _showEditProfileDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                try {
                  await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(() {}); // refresh UI
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Display name updated successfully! 🎉')),
                    );
                  }
                } catch (e) {
                  debugPrint('Failed to update name: $e');
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Guest';
    final email = user?.email ?? '';
    final roleAsync = ref.watch(userRoleProvider);
    final role = roleAsync.value ?? '';
    final isShopper = role == 'user';
    final isBrand = role == 'brand';
    final isAdmin = role == 'admin';

    // we still show the same tabs for everyone, but contents can differ
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        bottomNavigationBar: const StyleBottomNavigationBar(currentIndex: 4),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryPurple, primaryPink],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(radiusLarge),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(space16, space48, space16, space24),
                child: Column(
                  children: [
                    Hero(
                      tag: 'profile-avatar',
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : '?',
                          style: h2.copyWith(color: primaryPurple),
                        ),
                      ),
                    ),
                    const SizedBox(height: space12),
                    Text(displayName, style: h3.copyWith(color: Colors.white)),
                    const SizedBox(height: space4),
                    Text(email, style: bodySmall.copyWith(color: Colors.white70)),
                    const SizedBox(height: space12),
                    OutlinedButton(
                      onPressed: () {
                        debugPrint('Profile: Edit Profile clicked');
                        _showEditProfileDialog(context, displayName);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radiusMedium),
                        ),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                    const SizedBox(height: space24),
                    Row(
                      children: [
                        if (isShopper) ...const [
                          _StatCard(label: 'Saved Outfits', value: '24', icon: Icons.favorite),
                          SizedBox(width: space12),
                          _StatCard(
                              label: 'Purchases', value: '8', icon: Icons.shopping_bag_outlined),
                          SizedBox(width: space12),
                          _StatCard(label: 'Following', value: '18', icon: Icons.people_alt),
                        ] else if (isBrand) ...const [
                          _StatCard(label: 'Products', value: '12', icon: Icons.checkroom_outlined),
                          SizedBox(width: space12),
                          _StatCard(label: 'Orders', value: '58', icon: Icons.receipt_long),
                        ] else if (isAdmin) ...const [
                          _StatCard(label: 'Users', value: '1.2k', icon: Icons.people),
                          SizedBox(width: space12),
                          _StatCard(label: 'Brands', value: '84', icon: Icons.store),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                const TabBar(
                  indicatorColor: primaryPurple,
                  labelColor: primaryPurple,
                  unselectedLabelColor: textMuted,
                  tabs: [
                    Tab(text: 'Saved'),
                    Tab(text: 'History'),
                    Tab(text: 'Settings'),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                children: [
                  _SavedTab(role: role),
                  _HistoryTab(role: role),
                  _SettingsTab(role: role),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: space8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radiusLarge),
          color: Colors.white.withOpacity(0.15),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: space4),
            Text(value, style: h4.copyWith(color: Colors.white)),
            const SizedBox(height: space2),
            Text(label, style: caption.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _SavedTab extends StatelessWidget {
  final String role;
  const _SavedTab({required this.role});

  @override
  Widget build(BuildContext context) {
    if (role != 'user') {
      return Center(
        child: Text(
          'No saved items for your account type.',
          style: bodyMedium,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(space16),
      child: GridView.builder(
        itemCount: 0,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: space12,
          mainAxisSpacing: space12,
          childAspectRatio: 3 / 4.2,
        ),
        itemBuilder: (context, index) {
          return const SizedBox.shrink();
        },
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _HistoryTab extends StatelessWidget {
  final String role;
  const _HistoryTab({required this.role});

  @override
  Widget build(BuildContext context) {
    if (role == 'user') {
      return ListView.builder(
        padding: const EdgeInsets.all(space16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: space12),
            padding: const EdgeInsets.all(space12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radiusMedium),
              color: surfaceColor,
              boxShadow: cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #STYLE-${1200 + index}', style: bodyMedium.copyWith(color: textPrimary)),
                const SizedBox(height: space4),
                Text('Delivered • \$${189 + index * 20}', style: bodySmall),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms, delay: (index * 80).ms);
        },
      );
    } else if (role == 'brand') {
      return Center(
        child: Text('Brand purchase history not available.', style: bodyMedium),
      );
    } else {
      return Center(child: Text('Admin overview not shown here.', style: bodyMedium));
    }
  }
}

class _SettingsTab extends StatelessWidget {
  final String role;
  const _SettingsTab({required this.role});

  void _showDummySettingDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Text('The "$title" preference dashboard is fully initialized and synced in read-only sandbox mode.', style: const TextStyle(fontFamily: 'Inter')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cache', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to clear the style recommendations cache and active session metadata?', style: TextStyle(fontFamily: 'Inter')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App cache successfully cleared! ⚡'), duration: Duration(seconds: 2)),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: errorRed)),
        content: const Text('WARNING: This action is irreversible. All your virtual try-on data, outfits, and profile stats will be permanently removed.', style: TextStyle(fontFamily: 'Inter')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: errorRed, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                await AuthService.instance.logout();
                if (context.mounted) {
                  context.go('/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Your account has been deleted. We are sad to see you go! 😢')),
                  );
                }
              } catch (e) {
                // If reauthentication is needed, logout and notify
                await AuthService.instance.logout();
                if (context.mounted) {
                  context.go('/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log back in to verify security credentials before deleting your account.')),
                  );
                }
              }
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(space16),
      children: [
        Text('Account', style: bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: space8),
        _SettingsTile(
          title: 'Edit Profile',
          onTap: () {
            final user = FirebaseAuth.instance.currentUser;
            final currentName = user?.displayName ?? '';
            // edit display name
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Edit Profile', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: currentName),
                      onSubmitted: (val) async {
                        final name = val.trim();
                        if (name.isNotEmpty) {
                          await user?.updateDisplayName(name);
                          if (ctx.mounted) Navigator.pop(ctx);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        _SettingsTile(
          title: 'Change Password',
          onTap: () => _showDummySettingDialog(context, 'Change Password'),
        ),
        _SettingsTile(
          title: 'Email Preferences',
          onTap: () => _showDummySettingDialog(context, 'Email Preferences'),
        ),
        const SizedBox(height: space16),
        Text('Preferences', style: bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: space8),
        if (role == 'user') ...[
          _SettingsTile(
            title: 'Style Preferences',
            onTap: () => _showDummySettingDialog(context, 'Style Preferences'),
          ),
          _SettingsTile(
            title: 'Size Guide',
            onTap: () => _showDummySettingDialog(context, 'Size Guide'),
          ),
          _SettingsTile(
            title: 'Currency & Language',
            onTap: () => _showDummySettingDialog(context, 'Currency & Language'),
          ),
        ],
        if (role != 'user')
          _SettingsTile(
            title: 'Brand/Platform Settings',
            onTap: () => _showDummySettingDialog(context, 'Brand/Platform Settings'),
          ),
        const SizedBox(height: space16),
        Text('App', style: bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: space8),
        _SettingsTile(
          title: 'Notifications',
          isSwitch: true,
          onTap: () {},
        ),
        _SettingsTile(
          title: 'Dark Mode',
          isSwitch: true,
          onTap: () {},
        ),
        _SettingsTile(
          title: 'Clear Cache',
          onTap: () => _showClearCacheDialog(context),
        ),
        const SizedBox(height: space16),
        Text('Support', style: bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: space8),
        _SettingsTile(
          title: 'Help Center',
          onTap: () => _showDummySettingDialog(context, 'Help Center'),
        ),
        _SettingsTile(
          title: 'Contact Us',
          onTap: () => _showDummySettingDialog(context, 'Contact Us'),
        ),
        _SettingsTile(
          title: 'Privacy Policy',
          onTap: () => _showDummySettingDialog(context, 'Privacy Policy'),
        ),
        _SettingsTile(
          title: 'Terms of Service',
          onTap: () => _showDummySettingDialog(context, 'Terms of Service'),
        ),
        const SizedBox(height: space16),
        Text('Account Actions', style: bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: space8),
        _LogoutTile(),
        if (role == 'user')
          _SettingsTile(
            title: 'Delete Account',
            isDestructive: true,
            onTap: () => _showDeleteAccountDialog(context),
          ),
      ],
    );
  }
}

class _LogoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(
        'Logout',
        style: bodyMedium.copyWith(color: textPrimary),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await AuthService.instance.logout();
          if (context.mounted) context.go('/login');
        }
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final bool isSwitch;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    this.isSwitch = false,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(
        title,
        style: bodyMedium.copyWith(
          color: isDestructive ? errorRed : textPrimary,
        ),
      ),
      trailing: isSwitch
          ? Switch(
              value: true,
              onChanged: (_) {},
            )
          : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
