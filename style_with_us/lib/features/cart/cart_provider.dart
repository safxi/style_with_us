import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        'updatedAt': FieldValue.serverTimestamp(),
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
    _loadFromFirestore();
    return const CartState(isLoading: true);
  }

  // ── Firestore helpers ────────────────────────────────────────

  CollectionReference<Map<String, dynamic>>? get _cartRef {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart');
  }

  Future<void> _loadFromFirestore() async {
    final ref = _cartRef;
    if (ref == null) {
      state = const CartState();
      return;
    }

    try {
      final snapshot = await ref.get();
      final items = snapshot.docs
          .map((doc) => CartItem.fromMap(doc.data()))
          .toList();
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
      await _cartRef?.doc(item.skuId).set(item.toMap());
    } catch (_) {
      // Silent fail — local state is still correct
    }
  }

  void _deleteItem(String skuId) async {
    try {
      await _cartRef?.doc(skuId).delete();
    } catch (_) {}
  }

  void _deleteAll(List<String> skuIds) async {
    final ref = _cartRef;
    if (ref == null) return;
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final id in skuIds) {
        batch.delete(ref.doc(id));
      }
      await batch.commit();
    } catch (_) {}
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
