import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/theme/style_tokens.dart';
import '../../core/widgets/gradient_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  static const String routeName = 'order-success';

  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success animation
              SizedBox(
                height: 180,
                child: Lottie.asset('assets/animations/success_checkmark.json'),
              ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: space24),

              // Heading
              Text(
                'Order Placed! 🎉',
                style: h2,
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: space12),

              Text(
                'Your order has been confirmed and will be processed shortly.',
                style: bodyMedium.copyWith(color: textSecondary),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 450.ms),
              const SizedBox(height: space24),

              // Order ID card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(space16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radiusMedium),
                  color: primaryPurple.withOpacity(0.08),
                  border: Border.all(color: primaryPurple.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text('Order Reference', style: bodySmall.copyWith(color: textSecondary)),
                    const SizedBox(height: space4),
                    Text(
                      '#${orderId.toUpperCase()}',
                      style: h4.copyWith(color: primaryPurple, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: space4),
                    Text(
                      'Save this for tracking',
                      style: caption.copyWith(color: textSecondary),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
              const SizedBox(height: space32),

              // Actions
              GradientButton(
                text: 'Continue Shopping',
                onPressed: () => context.go('/home'),
              ).animate().fadeIn(duration: 400.ms, delay: 750.ms),
              const SizedBox(height: space12),
              OutlinedButton(
                onPressed: () => context.go('/profile'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radiusMedium),
                  ),
                ),
                child: const Text('View My Orders'),
              ).animate().fadeIn(duration: 400.ms, delay: 850.ms),
            ],
          ),
        ),
      ),
    );
  }
}
