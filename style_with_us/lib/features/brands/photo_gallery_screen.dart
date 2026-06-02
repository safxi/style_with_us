import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/network/api_client.dart';
import '../../core/theme/style_tokens.dart';

class BrandPhoto {
  final int id;
  final int brandId;
  final int? productId;
  final String imageUrl;
  final int uploaderId;
  final DateTime createdAt;

  BrandPhoto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        brandId = json['brand_id'],
        productId = json['product_id'],
        imageUrl = json['image_url'],
        uploaderId = json['uploader_id'],
        createdAt = DateTime.parse(json['created_at']);
}

class PhotoGalleryScreen extends StatefulWidget {
  static const String routeName = 'photo-gallery';

  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  final ApiClient _api = ApiClient();
  late Future<List<BrandPhoto>> _photosFuture;

  @override
  void initState() {
    super.initState();
    _photosFuture = _fetchPhotos();
  }

  Future<List<BrandPhoto>> _fetchPhotos() async {
    final uri = Uri.parse('${_api.baseUrl}/photos');
    final resp = await http.get(uri);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Failed to load photos: \\${resp.statusCode}');
    }
    final list = (jsonDecode(resp.body) as List<dynamic>?) ?? [];
    return list.map((e) => BrandPhoto.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Gallery')),
      body: FutureBuilder<List<BrandPhoto>>(
        future: _photosFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error loading photos: \\${snap.error}'));
          }
          final photos = snap.data ?? [];
          if (photos.isEmpty) {
            return const Center(child: Text('No photos uploaded yet.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(space16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: space12,
              mainAxisSpacing: space12,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final p = photos[index];
              return GestureDetector(
                onTap: () {},
                child: Image.network(p.imageUrl, fit: BoxFit.cover),
              );
            },
          );
        },
      ),
    );
  }
}
