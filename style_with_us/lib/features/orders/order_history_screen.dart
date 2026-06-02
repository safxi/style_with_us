import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';

final orderHistoryProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ApiClient();
  final response = await api.getJson('/orders/history');
  return response['orders'] as List<dynamic>;
});

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(orderHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order History', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: historyAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'No orders found.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                color: AppColors.surface,
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  collapsedIconColor: Colors.white,
                  iconColor: AppColors.primary,
                  title: Text(
                    'Order #${order['id']}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${order['status'].toString().toUpperCase()} • \$${order['total_price']}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  children: [
                    if (order['items'] != null)
                      ...((order['items'] as List).map((item) {
                        return ListTile(
                          title: Text(item['sku_id'] ?? 'Unknown Item', style: const TextStyle(color: Colors.white)),
                          subtitle: Text('Qty: ${item['quantity']} • \$${item['price']}', style: const TextStyle(color: Colors.white70)),
                        );
                      }).toList()),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(
          child: Text('Error loading orders:\n$err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
