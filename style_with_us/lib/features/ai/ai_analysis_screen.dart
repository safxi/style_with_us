import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/picked_image_widget.dart';
import '../../core/theme/style_tokens.dart';
import '../../core/widgets/gradient_button.dart';
import 'analysis_result_provider.dart';

class AIAnalysisScreen extends ConsumerStatefulWidget {
  static const String routeName = 'ai-analysis';

  const AIAnalysisScreen({super.key});

  @override
  ConsumerState<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

enum _AnalysisState { idle, processing, complete, error }

class _AIAnalysisScreenState extends ConsumerState<AIAnalysisScreen> {
  final _picker = ImagePicker();
  final _apiClient = ApiClient();

  _AnalysisState _state = _AnalysisState.idle;
  XFile? _selectedImage;
  double _progress = 0;
  String _statusText = 'Preparing...';
  String? _errorMessage;

  // ─────────────────────────────────────────────────────────────
  // Core flow: pick → upload → analyze → recommend → navigate
  // ─────────────────────────────────────────────────────────────

  void _showPermissionDeniedDialog(String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$type Permission Denied', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Text(
          'Please enable $type access in your system settings to continue with the AI Style Analysis.',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    debugPrint('AIAnalysis: Picking image from source: $source');
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        debugPrint('AIAnalysis: Camera permission status: $status');
        if (status.isPermanentlyDenied) {
          _showPermissionDeniedDialog('Camera');
          return;
        } else if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission is required to take a style photo! 📸')),
          );
          return;
        }
      }

      final image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image == null) {
        debugPrint('AIAnalysis: No image selected.');
        return;
      }

      setState(() {
        _selectedImage = image;
        _state = _AnalysisState.processing;
        _progress = 0;
        _statusText = 'Uploading your photo...';
        _errorMessage = null;
      });

      await _runAnalysis(image);
    } catch (e, st) {
      debugPrint('AIAnalysis: Error picking image: $e\n$st');
      setState(() {
        _state = _AnalysisState.error;
        _errorMessage = 'Failed to capture or pick image: $e';
      });
    }
  }

  Future<void> _runAnalysis(XFile image) async {
    try {
      // Step 1 – Upload to Firebase Storage
      _setProgress(0.2, 'Uploading your photo...');
      final imageUrl = await _uploadToStorage(image);

      // Step 2 – Analyze with ML backend
      _setProgress(0.45, 'Analyzing your style...');
      final uid = Supabase.instance.client.auth.currentUser?.id.hashCode ?? 0;
      final analyzeResponse = await _apiClient.postJson(
        '/ml/analyze',
        body: {'user_id': uid, 'image_url': imageUrl},
      );

      final analysisId = analyzeResponse['analysis_id'] as String;
      final bodyType = analyzeResponse['body_type'] as String;
      final bodyConfidence = (analyzeResponse['body_confidence'] as num).toDouble();
      final skinTone = analyzeResponse['skin_tone'] as String;
      final skinConfidence = (analyzeResponse['skin_confidence'] as num).toDouble();

      // Step 3 – Get recommendations
      _setProgress(0.75, 'Detecting colors and patterns...');
      final recommendResponse = await _apiClient.postJson(
        '/ml/recommend',
        body: {'user_id': uid, 'analysis_id': analysisId, 'limit': 6},
      );

      _setProgress(0.95, 'Finding your best matches...');
      final rawProducts = recommendResponse['products'] as List<dynamic>;
      final recommendations = rawProducts
          .map((e) => ProductRecommendation.fromJson(e as Map<String, dynamic>))
          .toList();

      // Step 4 – Store result in provider
      ref.read(analysisResultProvider.notifier).state = AnalysisResult(
        analysisId: analysisId,
        bodyType: bodyType,
        bodyConfidence: bodyConfidence,
        skinTone: skinTone,
        skinConfidence: skinConfidence,
        recommendations: recommendations,
      );

      // Step 5 – Mark complete and navigate
      _setProgress(1.0, 'Complete!');
      if (!mounted) return;
      setState(() => _state = _AnalysisState.complete);

      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;
      context.go('/results/$analysisId');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _AnalysisState.error;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  Future<String> _uploadToStorage(XFile image) async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anon';
    final filename = 'analysis_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'analysis/$userId/$filename';
    // upload to default bucket 'public' — ensure this bucket exists in your Supabase project
    await Supabase.instance.client.storage.from('public').upload(path, File(image.path));
    return Supabase.instance.client.storage.from('public').getPublicUrl(path);
  }

  void _setProgress(double value, String text) {
    if (!mounted) return;
    setState(() {
      _progress = value;
      _statusText = text;
    });
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('ApiException(422)')) {
      return 'Could not detect an outfit. Please use a clear full-body photo with good lighting.';
    }
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Cannot reach the server. Make sure the backend is running.';
    }
    return 'Something went wrong. Please try again.';
  }

  void _cancelProcessing() {
    setState(() {
      _state = _AnalysisState.idle;
      _selectedImage = null;
      _progress = 0;
      _errorMessage = null;
    });
  }

  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('AI Style Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoSheet,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(space16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: switch (_state) {
            _AnalysisState.idle => _buildUploadState(),
            _AnalysisState.processing => _buildProcessingState(),
            _AnalysisState.complete => _buildCompleteState(),
            _AnalysisState.error => _buildErrorState(),
          },
        ),
      ),
    );
  }

  // ── Upload state ──────────────────────────────────────────────

  Widget _buildUploadState() {
    return Column(
      key: const ValueKey('upload'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: space24),
        Expanded(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: Container(
                  padding: const EdgeInsets.all(space24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radiusLarge),
                    border: Border.all(
                      color: primaryPurple.withOpacity(0.3),
                      width: 1.5,
                    ),
                    color: surfaceColor,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: space8),
                      Container(
                        height: 72,
                        width: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: primaryGradient,
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            color: Colors.white, size: 32),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(
                              begin: const Offset(0.96, 0.96),
                              end: const Offset(1.04, 1.04),
                              duration: 1200.ms),
                      const SizedBox(height: space16),
                      Text('Upload Your Photo', style: h3),
                      const SizedBox(height: space8),
                      Text(
                        'Take a selfie or upload an outfit photo',
                        style: bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: space12),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: space24),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tips_and_updates_outlined, color: primaryPurple),
                    const SizedBox(width: space8),
                    Text('Best Results Tips',
                        style: bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: space12),
              const _TipItem(text: 'Good lighting'),
              const _TipItem(text: 'Full outfit visible'),
              const _TipItem(text: 'Clear background'),
            ],
          ),
        ),
        const SizedBox(height: space16),
        GradientButton(
          text: 'Take Photo',
          onPressed: () => _pickImage(ImageSource.camera),
        ),
        const SizedBox(height: space12),
        OutlinedButton(
          onPressed: () => _pickImage(ImageSource.gallery),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusMedium)),
          ),
          child: const Text('Choose from Gallery'),
        ),
      ],
    );
  }

  // ── Processing state ──────────────────────────────────────────

  Widget _buildProcessingState() {
    return Column(
      key: const ValueKey('processing'),
      children: [
        if (_selectedImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(radiusLarge),
            child: Stack(
              children: [
                buildPickedImage(_selectedImage, height: 240, fit: BoxFit.cover),
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.4),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radiusLarge),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                    ).animate().shimmer(duration: 1200.ms),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: space24),
        Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: Lottie.asset('assets/animations/ai_processing.json'),
              ),
              const SizedBox(height: space16),
              Text(_statusText, style: bodyLarge, textAlign: TextAlign.center)
                  .animate(key: ValueKey(_statusText))
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: space8),
              Text('This may take a few seconds', style: bodySmall),
              const SizedBox(height: space24),
              SizedBox(
                height: 120,
                width: 120,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _progress),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, _) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: value,
                          strokeWidth: 6,
                          strokeCap: StrokeCap.round,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(primaryPurple),
                          backgroundColor: primaryPurple.withOpacity(0.1),
                        ),
                        Center(
                          child: Text('${(value * 100).round()}%', style: h4),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: space16),
        TextButton(
          onPressed: _cancelProcessing,
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  // ── Complete state ────────────────────────────────────────────

  Widget _buildCompleteState() {
    return Center(
      key: const ValueKey('complete'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 160,
            child: Lottie.asset('assets/animations/success_checkmark.json'),
          ),
          const SizedBox(height: space16),
          Text('Analysis Complete! ✨', style: h3),
          const SizedBox(height: space8),
          Text(
            'Preparing your personalized recommendations...',
            style: bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      key: const ValueKey('error'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: errorRed, size: 72),
          const SizedBox(height: space16),
          Text('Analysis Failed', style: h3),
          const SizedBox(height: space12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: space24),
            child: Text(
              _errorMessage ?? 'Something went wrong. Please try again.',
              style: bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: space32),
          GradientButton(
            text: 'Try Again',
            onPressed: _cancelProcessing,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── Info sheet ────────────────────────────────────────────────

  void _showInfoSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLarge)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How AI Analysis Works', style: h3),
            const SizedBox(height: space12),
            Text(
              'Our ResNet50 model detects body shape and a skin tone classifier determines your color palette. We then match recommendations from partnered brands.',
              style: bodyMedium,
            ),
            const SizedBox(height: space16),
            Text('For best results:',
                style: bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: space8),
            const Text(
                '• Use good lighting\n• Keep your full outfit visible\n• Stand against a clean background'),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: space4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: successGreen, size: 18),
          const SizedBox(width: space8),
          Text(text, style: bodyMedium),
        ],
      ),
    );
  }
}
