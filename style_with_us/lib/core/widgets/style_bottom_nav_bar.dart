import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/style_tokens.dart';

class StyleBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const StyleBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _BottomItem(icon: PhosphorIconsFill.house, label: 'Home'),
      _BottomItem(icon: PhosphorIconsFill.magnifyingGlass, label: 'Explore'),
      _BottomItem(icon: PhosphorIconsFill.scan, label: 'AI Scan'),
      _BottomItem(icon: PhosphorIconsFill.storefront, label: 'Brands'),
      _BottomItem(icon: PhosphorIconsFill.user, label: 'Profile'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(space16, 0, space16, space16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radiusXLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(radiusXLarge),
              boxShadow: floatingShadow,
            ),
            padding: const EdgeInsets.symmetric(horizontal: space12, vertical: space8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isActive = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      debugPrint('StyleBottomNav: Tapped index $index (${item.label})');
                      if (index == currentIndex) return;

                      switch (index) {
                        case 0:
                          context.go('/home');
                          break;
                        case 1:
                          // Redirect Explore to brands screen or search
                          context.go('/brands');
                          break;
                        case 2:
                          // AI Scan is a prominent action that we should push on top of the stack
                          context.push('/ai-analysis');
                          break;
                        case 3:
                          context.go('/brands');
                          break;
                        case 4:
                          context.go('/profile');
                          break;
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(vertical: space4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              if (index == 2)
                                Container(
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: primaryGradient,
                                    boxShadow: floatingShadow,
                                  ),
                                ),
                              Icon(
                                item.icon,
                                size: index == 2 ? 24 : 22,
                                color: index == 2
                                    ? Colors.white
                                    : (isActive ? primaryPurple : textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                              color: isActive ? primaryPurple : textMuted,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomItem {
  final IconData icon;
  final String label;

  _BottomItem({required this.icon, required this.label});
}
