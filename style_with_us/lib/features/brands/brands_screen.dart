import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/style_tokens.dart';
import '../../core/widgets/search_bar.dart';
import '../../core/providers/brand_providers.dart';
import '../../core/widgets/style_bottom_nav_bar.dart';

class BrandsScreen extends ConsumerStatefulWidget {
  static const String routeName = 'brands';

  const BrandsScreen({super.key});

  @override
  ConsumerState<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends ConsumerState<BrandsScreen> {
  final _searchController = TextEditingController();
  String _activeFilter = 'All';

  final _filters = ['All', 'Premium', 'Affordable', 'Sustainable', 'Trending'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brands'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const StyleBottomNavigationBar(currentIndex: 3),
      body: Padding(
        padding: const EdgeInsets.all(space16),
        child: Column(
          children: [
            SearchBarWidget(
              controller: _searchController,
              hintText: 'Search brands...',
              onChanged: (_) {},
              onFilterTap: _showFilterSheet,
            ),
            const SizedBox(height: space12),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: space8),
                itemBuilder: (context, index) {
                  final label = _filters[index];
                  final isActive = label == _activeFilter;

                  return GestureDetector(
                    onTap: () => setState(() => _activeFilter = label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: space16, vertical: space8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radiusLarge),
                        gradient: isActive ? primaryGradient : null,
                        color: isActive ? null : surfaceColor,
                        border: isActive
                            ? null
                            : Border.all(
                                color: primaryPurple.withOpacity(0.2),
                              ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: bodySmall.copyWith(
                            color: isActive ? Colors.white : textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: space16),
            Expanded(
              child: Consumer(builder: (context, ref, _) {
                final brandsAsync = ref.watch(brandsProvider);
                return brandsAsync.when(
                  data: (brands) {
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: space12,
                        mainAxisSpacing: space12,
                        childAspectRatio: 3 / 3.6,
                      ),
                      itemCount: brands.length,
                      itemBuilder: (context, index) {
                        final brand = brands[index];
                        return _BrandCard(
                          index: index,
                          name: brand.name,
                          onTap: () => context.push('/brands/${brand.id}'),
                        )
                            .animate()
                            .fadeIn(duration: 350.ms, delay: (index * 60).ms)
                            .slideY(begin: 0.15, end: 0);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Failed to load brands: \\${e}')),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLarge)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Brands', style: h3),
              const SizedBox(height: space16),
              Text('Price Range', style: bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              RangeSlider(
                values: const RangeValues(50, 250),
                min: 0,
                max: 500,
                onChanged: (v) {},
              ),
              const SizedBox(height: space12),
              Text('Sort By', style: bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: space8),
              Column(
                children: [
                  RadioListTile(
                    value: 'popularity',
                    groupValue: 'popularity',
                    onChanged: (_) {},
                    title: const Text('Popularity'),
                  ),
                  RadioListTile(
                    value: 'newest',
                    groupValue: 'popularity',
                    onChanged: (_) {},
                    title: const Text('Newest'),
                  ),
                ],
              ),
              const SizedBox(height: space12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radiusMedium),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: primaryGradient,
                      borderRadius: BorderRadius.circular(radiusMedium),
                    ),
                    child: Center(
                      child: Text('Apply Filters', style: buttonText),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrandCard extends StatelessWidget {
  final int index;
  final String name;
  final VoidCallback? onTap;

  const _BrandCard({required this.index, required this.name, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radiusLarge),
          color: surfaceColor,
          boxShadow: cardShadow,
        ),
        padding: const EdgeInsets.all(space12),
        child: Column(
          children: [
            const SizedBox(height: space8),
            CircleAvatar(
              radius: 26,
              backgroundColor: backgroundColor,
              child: Text(
                'B${index + 1}',
                style: h4,
              ),
            ),
            const SizedBox(height: space12),
            Text(
              name,
              style: h4,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: space4),
            Text(
              '${8 + index} Products',
              style: caption,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: space8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radiusMedium),
                  ),
                ),
                child: const Text('Follow'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

