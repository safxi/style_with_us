import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../network/api_client.dart';

class Brand {
  final int id;
  final String name;
  final String? logoUrl;

  Brand({required this.id, required this.name, this.logoUrl});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo_url'] as String?,
    );
  }
}

class Product {
  final int id;
  final int brandId;
  final String name;
  final String? mainImageUrl;
  final double price;
  final String currency;

  Product({
    required this.id,
    required this.brandId,
    required this.name,
    this.mainImageUrl,
    required this.price,
    required this.currency,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      brandId: json['brand_id'],
      name: json['name'],
      mainImageUrl: json['main_image_url'] as String?,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'],
    );
  }
}

final _api = ApiClient();

final brandsProvider = FutureProvider<List<Brand>>((ref) async {
  final data = await _api.getJson('/brands');
  final list = (data as List<dynamic>?) ?? [];
  return list.map((e) => Brand.fromJson(e as Map<String, dynamic>)).toList();
});

final brandProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, brandId) async {
  final data = await _api.getJson('/brands/$brandId/products');
  final list = (data as List<dynamic>?) ?? [];
  return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
});
