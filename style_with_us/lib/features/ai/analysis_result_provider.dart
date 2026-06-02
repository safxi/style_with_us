import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the result of a completed AI analysis so the results screen can read it.
class AnalysisResult {
  const AnalysisResult({
    required this.analysisId,
    required this.bodyType,
    required this.bodyConfidence,
    required this.skinTone,
    required this.skinConfidence,
    required this.recommendations,
  });

  final String analysisId;
  final String bodyType;
  final double bodyConfidence;
  final String skinTone;
  final double skinConfidence;
  final List<ProductRecommendation> recommendations;

  /// Derive style tags from body type.
  List<String> get styleTags {
    switch (bodyType.toLowerCase()) {
      case 'hourglass':
        return ['Fitted', 'Wrap', 'Belt-friendly'];
      case 'pear':
        return ['A-line', 'Flare', 'High-waist'];
      case 'apple':
        return ['Empire Waist', 'Flowing', 'V-neck'];
      case 'rectangle':
        return ['Layering', 'Crop Tops', 'Color Blocking'];
      case 'inverted':
        return ['Wide Pants', 'Asymmetrical', 'Balance'];
      default:
        return ['Minimalist', 'Modern', 'Casual'];
    }
  }

  /// Overall match score (0–100) from top recommendation.
  int get matchScore =>
      recommendations.isNotEmpty ? (recommendations.first.score * 100).round() : 0;
}

class ProductRecommendation {
  const ProductRecommendation({
    required this.productId,
    required this.brandId,
    required this.score,
    required this.explanation,
    required this.rank,
  });

  final int productId;
  final int brandId;
  final double score;
  final String explanation;
  final int rank;

  factory ProductRecommendation.fromJson(Map<String, dynamic> json) {
    return ProductRecommendation(
      productId: json['product_id'] as int,
      brandId: json['brand_id'] as int,
      score: (json['score'] as num).toDouble(),
      explanation: json['explanation'] as String? ?? '',
      rank: json['rank'] as int? ?? 0,
    );
  }

  /// Generate a display name based on rank since backend returns product IDs only.
  String get displayName {
    const names = [
      'Urban Minimalist Set',
      'High-Waist Trouser Look',
      'Flowing Midi Ensemble',
    ];
    return rank > 0 && rank <= names.length ? names[rank - 1] : 'Style Look $rank';
  }

  double get price => 149.99 + (rank - 1) * 50.0;
  String get skuId => 'rec-${productId}-${brandId}';
}

/// Global in-memory state shared between AIAnalysisScreen and ResultsScreen.
final analysisResultProvider = NotifierProvider<AnalysisResultNotifier, AnalysisResult?>(AnalysisResultNotifier.new);

class AnalysisResultNotifier extends Notifier<AnalysisResult?> {
  @override
  AnalysisResult? build() => null;

  set state(AnalysisResult? value) {
    super.state = value;
  }
}
