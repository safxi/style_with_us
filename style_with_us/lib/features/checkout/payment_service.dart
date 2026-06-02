import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../cart/cart_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OrderSummary — returned by the backend
// ─────────────────────────────────────────────────────────────────────────────

class OrderSummary {
  OrderSummary({
    required this.orderId,
    required this.amountTotal,
    required this.currency,
    required this.paymentGateway,
    this.stripeClientSecret,
    this.razorpayOrderId,
  });

  final int orderId;
  final double amountTotal;
  final String currency;
  final String paymentGateway;
  final String? stripeClientSecret;
  final String? razorpayOrderId;
}

// ─────────────────────────────────────────────────────────────────────────────
// PaymentService
// ─────────────────────────────────────────────────────────────────────────────

class PaymentService {
  PaymentService(this._apiClient);

  final ApiClient _apiClient;

  /// Create order on the backend and persist it to Firestore.
  /// Returns the [OrderSummary] from the backend.
  Future<OrderSummary> createOrder({
    required CartState cart,
    String paymentGateway = 'stripe',
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userId = uid.hashCode;

    final items = cart.items
        .map(
          (e) => {
            'product_id': e.productId,
            'sku_id': e.skuId,
            'quantity': e.quantity,
            'unit_price': e.price,
          },
        )
        .toList();

    // 1) Call backend to create order record
    final response = await _apiClient.postJson(
      '/orders/create',
      body: {
        'user_id': userId,
        'items': items,
        'currency': 'USD',
        'payment_gateway': paymentGateway,
      },
    );

    final summary = OrderSummary(
      orderId: response['order_id'] as int,
      amountTotal: (response['amount_total'] as num).toDouble(),
      currency: response['currency'] as String,
      paymentGateway: response['payment_gateway'] as String,
      stripeClientSecret: response['stripe_client_secret'] as String?,
      razorpayOrderId: response['razorpay_order_id'] as String?,
    );

    // 2) Save order to Firestore so the user can view it in their profile/history
    await _saveOrderToFirestore(uid, summary, cart);

    return summary;
  }

  Future<void> confirmOrder({
    required int orderId,
    required String paymentStatus,
    String? gatewayReference,
  }) async {
    await _apiClient.postJson(
      '/orders/confirm',
      body: {
        'order_id': orderId,
        'payment_status': paymentStatus,
        if (gatewayReference != null) 'gateway_reference': gatewayReference,
      },
    );
  }

  Future<void> _saveOrderToFirestore(
    String uid,
    OrderSummary summary,
    CartState cart,
  ) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(summary.orderId.toString())
        .set({
      'orderId': summary.orderId,
      'userId': uid,
      'amountTotal': summary.amountTotal,
      'currency': summary.currency,
      'paymentGateway': summary.paymentGateway,
      'status': 'pending_payment',
      'items': cart.items
          .map((e) => {
                'productId': e.productId,
                'skuId': e.skuId,
                'name': e.name,
                'price': e.price,
                'quantity': e.quantity,
              })
          .toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final paymentServiceProvider = Provider<PaymentService>(
  (ref) => PaymentService(ref.read(apiClientProvider)),
);
