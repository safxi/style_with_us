import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/style_tokens.dart';
import '../../core/widgets/gradient_button.dart';
import '../cart/cart_provider.dart';
import 'analysis_result_provider.dart';

class ResultsScreen extends ConsumerWidget {
  static const String routeName = 'results';

  final String analysisId;

  const ResultsScreen({super.key, required this.analysisId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(analysisResultProvider);

    // If no result in memory (e.g. app restart), show fallback
    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Style Match')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 64, color: textSecondary),
              const SizedBox(height: space16),
              Text('No analysis found', style: h4),
              const SizedBox(height: space8),
              Text('Please run a new AI analysis.', style: bodyMedium),
              const SizedBox(height: space24),
              GradientButton(
                text: 'Start Analysis',
                onPressed: () => context.go('/ai-analysis'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Style Match'),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryCard(result: result),
            const SizedBox(height: space24),
            if (result.recommendations.isNotEmpty) ...[
              _PerfectMatchCard(
                recommendation: result.recommendations.first,
                ref: ref,
                context: context,
              ),
              const SizedBox(height: space24),
            ],
            if (result.recommendations.length > 1)
              _SimilarStylesSection(
                recommendations: result.recommendations.skip(1).toList(),
                ref: ref,
                context: context,
              ),
            const SizedBox(height: space24),
            _CompleteTheLookSection(
              recommendations: result.recommendations,
              ref: ref,
              context: context,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(space16, space8, space16, space16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go('/ai-analysis'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radiusMedium)),
                ),
                child: const Text('Try Another Photo'),
              ),
            ),
            const SizedBox(width: space12),
            Expanded(
              child: GradientButton(
                text: 'Go to Cart',
                onPressed: () => context.go('/cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Card
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final AnalysisResult result;
  const _SummaryCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radiusLarge),
        gradient: softGradient,
        border: Border.all(width: 1.5, color: primaryPurple.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Style Summary', style: h4),
          const SizedBox(height: space8),
          // Body type + skin tone badges
          Wrap(
            spacing: 8,
            children: [
              _InfoBadge(
                icon: Icons.accessibility_new,
                label: _capitalize(result.bodyType),
              ),
              _InfoBadge(
                icon: Icons.palette_outlined,
                label: '${_capitalize(result.skinTone)} skin',
              ),
            ],
          ),
          const SizedBox(height: space16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Style Tags', style: bodySmall),
                    const SizedBox(height: space8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result.styleTags
                          .map((tag) => _TagChip(label: tag))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: space16),
              SizedBox(
                height: 100,
                width: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: result.matchScore / 100),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, _) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 6,
                          strokeCap: StrokeCap.round,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(primaryPurple),
                          backgroundColor: primaryPurple.withOpacity(0.1),
                        );
                      },
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${result.matchScore}%', style: h3),
                          Text('Match',
                              style: bodySmall.copyWith(color: textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// Perfect Match
// ─────────────────────────────────────────────────────────────────────────────

class _PerfectMatchCard extends StatelessWidget {
  final ProductRecommendation recommendation;
  final WidgetRef ref;
  final BuildContext context;

  const _PerfectMatchCard({
    required this.recommendation,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext buildContext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Perfect Match', style: h4),
        const SizedBox(height: space12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radiusLarge),
            boxShadow: floatingShadow,
            color: surfaceColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder with gradient
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(radiusLarge)),
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryPurple.withOpacity(0.2),
                            primaryPink.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const IconButton(
                          icon: Icon(Icons.favorite_border),
                          onPressed: null,
                        ),
                      ),
                    ),
                    // Match score badge
                    Positioned(
                      left: 16,
                      top: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: space10, vertical: space4),
                        decoration: BoxDecoration(
                          gradient: primaryGradient,
                          borderRadius: BorderRadius.circular(radiusMedium),
                        ),
                        child: Text(
                          '${(recommendation.score * 100).round()}% Match',
                          style: caption.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recommendation.displayName, style: h3),
                    const SizedBox(height: space4),
                    Text(
                      recommendation.explanation,
                      style: bodySmall.copyWith(color: textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: space12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => primaryGradient
                              .createShader(
                                  Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                          child: Text(
                            '\$${recommendation.price.toStringAsFixed(2)}',
                            style: h3.copyWith(color: Colors.white),
                          ),
                        ),
                        GradientButton(
                          text: 'Add to Cart',
                          onPressed: () {
                            ref.read(cartProvider.notifier).addItem(
                                  CartItem(
                                    productId: recommendation.productId,
                                    skuId: recommendation.skuId,
                                    name: recommendation.displayName,
                                    price: recommendation.price,
                                  ),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart! 🛍️')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Similar Styles
// ─────────────────────────────────────────────────────────────────────────────

class _SimilarStylesSection extends StatelessWidget {
  final List<ProductRecommendation> recommendations;
  final WidgetRef ref;
  final BuildContext context;

  const _SimilarStylesSection({
    required this.recommendations,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext buildContext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Similar Styles', style: h4),
        const SizedBox(height: space12),
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.78),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final rec = recommendations[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radiusLarge),
                  color: surfaceColor,
                  boxShadow: cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(radiusLarge),
                      ),
                      child: Container(
                        height: 130,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryBlue.withOpacity(0.18),
                              primaryPurple.withOpacity(0.18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(space12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rec.displayName,
                              style: bodyMedium.copyWith(color: textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: space4),
                          Text(
                            rec.explanation,
                            style: bodySmall.copyWith(color: textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: space4),
                          ShaderMask(
                            shaderCallback: (bounds) => primaryGradient.createShader(
                                Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                            child: Text(
                              '\$${rec.price.toStringAsFixed(2)}',
                              style: h4.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: (index * 80).ms);
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Complete the Look
// ─────────────────────────────────────────────────────────────────────────────

class _CompleteTheLookSection extends StatelessWidget {
  final List<ProductRecommendation> recommendations;
  final WidgetRef ref;
  final BuildContext context;

  const _CompleteTheLookSection({
    required this.recommendations,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext buildContext) {
    final items = recommendations.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Complete the Look', style: h4),
        const SizedBox(height: space12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: space12,
            mainAxisSpacing: space12,
            childAspectRatio: 0.75,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final rec = items[index];
            return GestureDetector(
              onLongPress: () {
                showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  backgroundColor: surfaceColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(radiusLarge)),
                  ),
                  builder: (sheetCtx) {
                    return Padding(
                      padding: const EdgeInsets.all(space24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rec.displayName, style: h3),
                          const SizedBox(height: space8),
                          Text(rec.explanation, style: bodyMedium),
                          const SizedBox(height: space16),
                          GradientButton(
                            text: 'Add to Cart — \$${rec.price.toStringAsFixed(2)}',
                            onPressed: () {
                              ref.read(cartProvider.notifier).addItem(
                                    CartItem(
                                      productId: rec.productId,
                                      skuId: rec.skuId,
                                      name: rec.displayName,
                                      price: rec.price,
                                    ),
                                  );
                              Navigator.of(sheetCtx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to cart! 🛍️')),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radiusMedium),
                        gradient: LinearGradient(
                          colors: [
                            primaryPurple.withOpacity(0.16),
                            primaryPink.withOpacity(0.16),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${(rec.score * 100).round()}%',
                          style: bodySmall.copyWith(
                              color: primaryPurple, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: space4),
                  Text(
                    rec.displayName,
                    style: bodySmall.copyWith(color: textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms, delay: (index * 60).ms);
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: space12, vertical: space6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radiusLarge),
        color: surfaceColor,
        border: Border.all(color: primaryPurple.withOpacity(0.2)),
      ),
      child: Text(label, style: bodySmall.copyWith(color: textPrimary)),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: space10, vertical: space4),
      decoration: BoxDecoration(
        color: primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryPurple),
          const SizedBox(width: space4),
          Text(label,
              style: bodySmall.copyWith(
                  color: primaryPurple, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
