import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/style_tokens.dart';

class ArTryOnScreen extends StatefulWidget {
  static const String routeName = 'ar-try-on';

  const ArTryOnScreen({super.key});

  @override
  State<ArTryOnScreen> createState() => _ArTryOnScreenState();
}

class _ArTryOnScreenState extends State<ArTryOnScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _errorMessage = 'Camera permission required for AR Try-On');
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'No camera found on device');
        return;
      }
      
      // Prefer front camera for virtual try-on
      CameraDescription? frontCamera;
      for (final c in cameras) {
        if (c.lensDirection == CameraLensDirection.front) {
          frontCamera = c;
          break;
        }
      }
      final selectedCamera = frontCamera ?? cameras.first;

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Failed to initialize camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('AR Fitting Room', style: TextStyle(color: Colors.white)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 64),
              const SizedBox(height: space16),
              Text(
                _errorMessage,
                style: h4.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: space24),
              ElevatedButton(
                onPressed: _initCamera,
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator(color: primaryPurple));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1) Camera Feed
        CameraPreview(_controller!),

        // 2) Draggable/Scalable Digital Garment
        InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          minScale: 0.5,
          maxScale: 3.5,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: Center(
            child: Opacity(
              opacity: 0.9,
              child: Image.network(
                // Example: A transparent shirt icon or image.
                'https://cdn-icons-png.flaticon.com/512/863/863684.png', 
                width: 250,
                height: 250,
                fit: BoxFit.contain,
                color: primaryPurple.withOpacity(0.8),
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),
        ),

        // 3) UI Overlay Directions
        Positioned(
          bottom: space32,
          left: space16,
          right: space16,
          child: Container(
            padding: const EdgeInsets.all(space12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(radiusLarge),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pinch, color: Colors.white, size: 20),
                const SizedBox(width: space8),
                Text(
                  'Pinch to scale, drag to adjust position',
                  style: bodySmall.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
