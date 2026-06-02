import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/style_tokens.dart';
import '../../core/widgets/gradient_button.dart';
import '../cart/cart_provider.dart';

class BrandProductsScreen extends ConsumerWidget {
  static const String routeName = 'brand-products';

  final String brandId;

  const BrandProductsScreen({super.key, required this.brandId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartProvider).items.fold<int>(0, (sum, e) => sum + e.quantity);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryPurple, primaryPink],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: space24),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: Text(
                          brandId.isEmpty ? 'B' : brandId[0].toUpperCase(),
                          style: h3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(space16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Text('Brand $brandId', style: h2),
                  const SizedBox(height: space8),
                  Text('12.4k followers', style: bodyMedium),
                  const SizedBox(height: space12),
                  Wrap(
                    spacing: 8,
                    children: const [
                      Chip(label: Text('Minimalist')),
                      Chip(label: Text('Premium')),
                    ],
                  ),
                  const SizedBox(height: space16),
                  Text(
                    'Discover curated pieces from this brand. This is placeholder copy for the brand description.',
                    style: bodyMedium,
                  ),
                  const SizedBox(height: space24),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: space16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: space12,
                mainAxisSpacing: space12,
                childAspectRatio: 3 / 4.4,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _BrandProductCard(index: index)
                      .animate()
                      .fadeIn(duration: 350.ms, delay: (index * 60).ms)
                      .slideY(begin: 0.15, end: 0);
                },
                childCount: 10,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/cart'),
        backgroundColor: primaryPurple,
        icon: const Icon(Icons.shopping_bag_outlined),
        label: Text('Cart ($cartCount)'),
      ),
    );
  }
}

class _BrandProductCard extends ConsumerWidget {
  final int index;

  const _BrandProductCard({required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int productId = 1000 + index;
    return GestureDetector(
      onTap: () => context.go('/virtual-try-on/$productId'),
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          backgroundColor: surfaceColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLarge)),
          ),
          builder: (sheetCtx) {
            return Padding(
              padding: const EdgeInsets.all(space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product ${index + 1}', style: h3),
                  const SizedBox(height: space8),
                  Text('\$${79 + index * 5} · Premium quality piece', style: bodyMedium),
                  const SizedBox(height: space16),
                  GradientButton(
                    text: 'Add to Cart',
                    onPressed: () {
                      ref.read(cartProvider.notifier).addItem(
                        CartItem(
                          productId: 1000 + index,
                          skuId: 'brand-prod-$index',
                          name: 'Product ${index + 1}',
                          price: 79 + index * 5.0,
                        ),
                      );
                      Navigator.of(sheetCtx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart!')),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radiusMedium),
          color: surfaceColor,
          boxShadow: cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(radiusMedium)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryPurple.withOpacity(0.18),
                        primaryPink.withOpacity(0.18),
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product ${index + 1}', style: bodyMedium.copyWith(color: textPrimary)),
                  const SizedBox(height: space4),
                  ShaderMask(
                    shaderCallback: (bounds) => primaryGradient
                        .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: Text(
                      '\$${79 + index * 5}',
                      style: h4.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: space4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: accentGold),
                      const SizedBox(width: 4),
                      Text('4.${index % 5} (123)', style: caption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

