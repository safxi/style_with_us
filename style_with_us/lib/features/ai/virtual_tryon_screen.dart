import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/picked_image_widget.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/style_tokens.dart';
import '../../core/widgets/gradient_button.dart';

class VirtualTryOnScreen extends StatefulWidget {
  static const String routeName = 'virtual-try-on';

  final String productId;

  const VirtualTryOnScreen({
    super.key,
    required this.productId,
  });

  @override
  State<VirtualTryOnScreen> createState() => _VirtualTryOnScreenState();
}

enum _TryOnState { idle, processing, complete }

class _VirtualTryOnScreenState extends State<VirtualTryOnScreen> {
  final ImagePicker _picker = ImagePicker();
  final ApiClient _apiClient = ApiClient();

  _TryOnState _state = _TryOnState.idle;
  XFile? _selectedImage;
  String? _resultImageUrl;
  String? _explanation;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 80);
    if (image == null) return;
    setState(() {
      _selectedImage = image;
      _state = _TryOnState.idle;
      _resultImageUrl = null;
      _explanation = null;
    });
  }

  Future<void> _runTryOn() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a full-body photo first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _state = _TryOnState.processing;
    });

    try {
      final imageUrl = await _uploadToStorage(_selectedImage!);
      final int productIdInt = int.tryParse(widget.productId) ?? 0;
      final uidHash = Supabase.instance.client.auth.currentUser?.id.hashCode ?? 0;
      final response = await _apiClient.postJson(
        '/ml/virtual-tryon',
        body: {
          'user_id': uidHash,
          'product_id': productIdInt,
          'image_url': imageUrl,
        },
      );

      if (!mounted) return;
      setState(() {
        _state = _TryOnState.complete;
        _resultImageUrl = response['result_image_url'] as String?;
        _explanation = response['explanation'] as String?;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      setState(() {
        _state = _TryOnState.idle;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _uploadToStorage(XFile image) async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'anon';
    final filename = 'tryon_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'tryon/$userId/$filename';
    await Supabase.instance.client.storage.from('public').upload(path, File(image.path));
    return Supabase.instance.client.storage.from('public').getPublicUrl(path);
  }

  @override
  Widget build(BuildContext context) {
    final productLabel = 'Product ${widget.productId}';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('AI Virtual Try-On'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showModalBottomSheet(
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
                      Text('How Try-On Works', style: h3),
                      const SizedBox(height: space12),
                      Text(
                        'We will use AI to place this outfit on your uploaded photo so you can preview the fit and vibe before buying.',
                        style: bodyMedium,
                      ),
                      const SizedBox(height: space16),
                      Text(
                        'For best results:',
                        style: bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: space8),
                      const Text('• Stand straight in frame\n• Use good lighting\n• Keep background simple'),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(productLabel, style: h3),
            const SizedBox(height: space4),
            Text(
              'Preview this look directly on you.',
              style: bodyMedium.copyWith(color: textSecondary),
            ),
            const SizedBox(height: space16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: switch (_state) {
                  _TryOnState.idle => _buildIdleState(),
                  _TryOnState.processing => _buildProcessingState(),
                  _TryOnState.complete => _buildCompleteState(),
                },
              ),
            ),
            const SizedBox(height: space16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radiusMedium),
                      ),
                    ),
                    child: const Text('Choose Photo'),
                  ),
                ),
                const SizedBox(width: space12),
                Expanded(
                  child: GradientButton(
                    text: _state == _TryOnState.complete ? 'Try Again' : 'Generate Try-On',
                    isLoading: _isLoading,
                    onPressed: _state == _TryOnState.complete ? _runTryOn : _runTryOn,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleState() {
    return Center(
      key: const ValueKey('idle'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(radiusLarge),
              child: buildPickedImage(_selectedImage, height: 220, fit: BoxFit.cover),
            )
          else
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radiusLarge),
                border: Border.all(
                  color: primaryPurple.withOpacity(0.3),
                ),
              ),
              child: const Center(
                child: Text('Select a full-body photo to begin'),
              ),
            ),
          const SizedBox(height: space16),
          Text(
            'Upload or choose a photo, then tap "Generate Try-On" to see this look on you.',
            style: bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingState() {
    return Center(
      key: const ValueKey('processing'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 80,
            width: 80,
            child: CircularProgressIndicator(
              strokeWidth: 5,
              valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
            ),
          ).animate().scale(begin: const Offset(0.9, 0.9), end: const Offset(1.05, 1.05)),
          const SizedBox(height: space16),
          Text(
            'Creating your AI try-on...',
            style: bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: space8),
          Text(
            'This usually takes a few seconds.',
            style: bodySmall.copyWith(color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteState() {
    return SingleChildScrollView(
      key: const ValueKey('complete'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_resultImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(radiusLarge),
              child: Image.network(
                _resultImageUrl!,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: space16),
          if (_explanation != null)
            Text(
              _explanation!,
              style: bodyMedium,
            ),
        ],
      ),
    );
  }
}

