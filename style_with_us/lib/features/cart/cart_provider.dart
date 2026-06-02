import 'package:supabase_flutter/supabase_flutter.dart';
// Firebase/Firestore replaced by Supabase
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CartItem model
// ─────────────────────────────────────────────────────────────────────────────

class CartItem {
  CartItem({
    required this.productId,
    required this.skuId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
  });

  final int productId;
  final String skuId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        skuId: skuId,
        name: name,
        price: price,
        quantity: quantity ?? this.quantity,
        imageUrl: imageUrl,
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'skuId': skuId,
        'name': name,
        'price': price,
        'quantity': quantity,
      'imageUrl': imageUrl,
      'updatedAt': DateTime.now().toIso8601String(),
      };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
        productId: map['productId'] as int? ?? 0,
        skuId: map['skuId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        quantity: map['quantity'] as int? ?? 1,
        imageUrl: map['imageUrl'] as String?,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// CartState
// ─────────────────────────────────────────────────────────────────────────────

class CartState {
  const CartState({this.items = const [], this.isLoading = false});

  final List<CartItem> items;
  final bool isLoading;

  double get subtotal =>
      items.fold(0, (total, item) => total + item.price * item.quantity);

  CartState copyWith({List<CartItem>? items, bool? isLoading}) => CartState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// CartNotifier — syncs with Firestore users/{uid}/cart/{skuId}
// ─────────────────────────────────────────────────────────────────────────────

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    // Kick off async load — return empty state immediately
    _loadFromSupabase();
    return const CartState(isLoading: true);
  }

  // ── Firestore helpers ────────────────────────────────────────

  Future<String?> get _userId async => Supabase.instance.client.auth.currentUser?.id;


  Future<void> _loadFromSupabase() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      state = const CartState();
      return;
    }
    try {
      final res = await Supabase.instance.client.from('cart').select().eq('user_id', uid);
      final rows = (res as List<dynamic>?) ?? [];
      final items = rows.map((r) => CartItem.fromMap(Map<String, dynamic>.from(r as Map))).toList();
      state = CartState(items: items);
    } catch (_) {
      state = const CartState();
    }
  }

  // ── Public actions ───────────────────────────────────────────

  void addItem(CartItem item) {
    final existingIndex = state.items
        .indexWhere((e) => e.productId == item.productId && e.skuId == item.skuId);

    List<CartItem> updated;
    CartItem toWrite;

    if (existingIndex >= 0) {
      updated = [...state.items];
      final existing = updated[existingIndex];
      toWrite = existing.copyWith(quantity: existing.quantity + item.quantity);
      updated[existingIndex] = toWrite;
    } else {
      toWrite = item;
      updated = [...state.items, item];
    }

    state = state.copyWith(items: updated);
    _upsertItem(toWrite); // fire-and-forget
  }

  void removeItem(String skuId) {
    state = state.copyWith(
      items: state.items.where((e) => e.skuId != skuId).toList(),
    );
    _deleteItem(skuId);
  }

  void clear() {
    final oldItems = state.items;
    state = const CartState();
    _deleteAll(oldItems.map((e) => e.skuId).toList());
  }

  // ── Firestore writes (fire-and-forget, non-blocking) ─────────

  void _upsertItem(CartItem item) async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;
      final payload = item.toMap()..addAll({'user_id': uid, 'skuId': item.skuId});
      await Supabase.instance.client.from('cart').upsert(payload);
    } catch (_) {
      // Silent fail — local state is still correct
    }
  }

  void _deleteItem(String skuId) async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;
      await Supabase.instance.client.from('cart').delete().match({'user_id': uid, 'skuId': skuId});
    } catch (_) {}
  }

  void _deleteAll(List<String> skuIds) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      for (final id in skuIds) {
        await Supabase.instance.client.from('cart').delete().match({'user_id': uid, 'skuId': id});
      }
    } catch (_) {}
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
