import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/style_tokens.dart';
import 'cart_provider.dart';

class CartScreen extends ConsumerWidget {
  static const String routeName = 'cart';

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart.items.isEmpty
          ? Center(
              child: Text(
                'Your cart is empty',
                style: bodyMedium,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(space16),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radiusMedium),
                        ),
                        tileColor: surfaceColor,
                        title: Text(item.name, style: bodyMedium),
                        subtitle: Text('Qty: ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: h4,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () =>
                                  ref.read(cartProvider.notifier).removeItem(item.skuId),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: space8),
                    itemCount: cart.items.length,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(space16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: bodyMedium),
                          Text(
                            '\$${cart.subtotal.toStringAsFixed(2)}',
                            style: h4,
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
                          onPressed: cart.items.isEmpty
                              ? null
                              : () => context.go('/checkout'),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: primaryGradient,
                              borderRadius: BorderRadius.circular(radiusMedium),
                            ),
                            child: Center(
                              child: Text(
                                'Proceed to Checkout',
                                style: buttonText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

