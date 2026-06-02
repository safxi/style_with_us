import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/theme/style_tokens.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = 'onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    context.go('/login');
  }

  void _onNext() {
    if (_currentIndex == 2) {
      context.go('/login');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: softGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: space16, vertical: space12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _onSkip,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (context, index) => pages[index],
                ),
              ),
              const SizedBox(height: space16),
              SmoothPageIndicator(
                controller: _pageController,
                count: pages.length,
                effect: ExpandingDotsEffect(
                  expansionFactor: 3,
                  spacing: 8,
                  radius: 12,
                  dotWidth: 8,
                  dotHeight: 8,
                  dotColor: textMuted.withOpacity(0.3),
                  activeDotColor: primaryPurple,
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: space24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: space24, vertical: space24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radiusMedium),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _onNext,
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: primaryGradient,
                        borderRadius: BorderRadius.circular(radiusMedium),
                        boxShadow: floatingShadow,
                      ),
                      child: Center(
                        child: Text(
                          _currentIndex == 2 ? 'Get Started' : 'Next',
                          style: buttonText,
                        ),
                      ),
                    ),
                  ),
                ).animate().scale(duration: 200.ms, curve: Curves.easeInOut),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPages() {
    return [
      _OnboardingPage(
        lottieAsset: 'assets/animations/fashion_items.json',
        title: 'Discover Your Style',
        subtitle: 'AI-powered fashion recommendations tailored just for you',
      ),
      _OnboardingPage(
        lottieAsset: 'assets/animations/camera_upload.json',
        title: 'Upload & Analyze',
        subtitle: 'Take a photo and let our AI analyze your style preferences',
      ),
      _OnboardingPage(
        lottieAsset: 'assets/animations/shopping_bags.json',
        title: 'Shop Personalized Looks',
        subtitle: 'Get curated outfits from premium brands that match your vibe',
      ),
    ];
  }
}

class _OnboardingPage extends StatelessWidget {
  final String lottieAsset;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.lottieAsset,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Builder(
              builder: (context) {
                final Widget lottie = Lottie.asset(
                  lottieAsset,
                  repeat: true,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                );
                return lottie
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
              },
            ),
          ),
          const SizedBox(height: space24),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(title, style: h2, textAlign: TextAlign.center)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 150.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                const SizedBox(height: space16),
                Text(
                  subtitle,
                  style: bodyLarge.copyWith(color: textSecondary),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 250.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
              ],
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

