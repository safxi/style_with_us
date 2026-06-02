import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/style_tokens.dart';
import '../../core/widgets/gradient_button.dart';
import '../cart/cart_provider.dart';
import 'payment_service.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  static const String routeName = 'checkout';

  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isPlacingOrder = false;
  String? _errorMessage;

  Future<void> _handlePlaceOrder() async {
    final cart = ref.read(cartProvider);
    if (cart.items.isEmpty) return;

    setState(() {
      _isPlacingOrder = true;
      _errorMessage = null;
    });

    try {
      final paymentService = ref.read(paymentServiceProvider);

      // Create order on backend + save to Firestore
      final summary = await paymentService.createOrder(cart: cart);

      if (summary.stripeClientSecret != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: summary.stripeClientSecret!,
            merchantDisplayName: 'Style With Us',
          ),
        );
        await Stripe.instance.presentPaymentSheet();
      }

      await paymentService.confirmOrder(
        orderId: summary.orderId,
        paymentStatus: 'PAID',
      );

      // Clear cart after successful order
      ref.read(cartProvider.notifier).clear();

      // Navigate to success screen
      if (!mounted) return;
      context.go('/order-success/${summary.orderId}');
    } catch (e) {
      setState(() {
        _errorMessage = _friendlyError(e.toString());
      });
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  String _friendlyError(String e) {
    if (e.contains('Connection refused') || e.contains('SocketException')) {
      return 'Cannot reach server. Ensure the backend is running on port 8000.';
    }
    if (e.contains('400')) return 'Invalid order data. Please check your cart.';
    return 'Failed to place order. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary', style: h3),
            const SizedBox(height: space12),

            // Items list
            Expanded(
              child: ListView.separated(
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final item = cart.items[i];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.name, style: bodyMedium),
                    subtitle: Text('Qty: ${item.quantity}',
                        style: bodySmall.copyWith(color: textSecondary)),
                    trailing: Text(
                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: bodyMedium.copyWith(
                          color: textPrimary, fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ),

            const Divider(),
            const SizedBox(height: space12),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: bodyLarge),
                ShaderMask(
                  shaderCallback: (bounds) => primaryGradient
                      .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: Text(
                    '\$${cart.subtotal.toStringAsFixed(2)}',
                    style: h3.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: space24),

            // Place Order button
            GradientButton(
              text: _isPlacingOrder ? 'Placing Order...' : 'Place Order',
              onPressed: (cart.items.isEmpty || _isPlacingOrder)
                  ? null
                  : () => _handlePlaceOrder(),
            ),

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: space12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(space12),
                decoration: BoxDecoration(
                  color: errorRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(radiusMedium),
                  border: Border.all(color: errorRed.withOpacity(0.3)),
                ),
                child: Text(_errorMessage!,
                    style: bodySmall.copyWith(color: errorRed)),
              ),
            ],
            const SizedBox(height: space8),
          ],
        ),
      ),
    );
  }
}
