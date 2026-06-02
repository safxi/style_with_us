
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_client.dart';

class BrandUploadScreen extends StatefulWidget {
  const BrandUploadScreen({super.key});

  @override
  State<BrandUploadScreen> createState() => _BrandUploadScreenState();
}

class _BrandUploadScreenState extends State<BrandUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _picked;
  final TextEditingController _brandIdController = TextEditingController();
  final TextEditingController _productIdController = TextEditingController();
  bool _isUploading = false;
  final ApiClient _api = ApiClient();

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) setState(() => _picked = img);
  }

  Future<void> _submit() async {
    if (_picked == null || _brandIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image and enter Brand ID')));
      return;
    }
    
    setState(() => _isUploading = true);
    try {
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      final uri = Uri.parse('${_api.baseUrl}/photos/');
      
      // Map specifically to FastAPI Form Models
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['brand_id'] = _brandIdController.text;
      if (_productIdController.text.isNotEmpty) {
        request.fields['product_id'] = _productIdController.text;
      }
      request.files.add(await http.MultipartFile.fromPath('file', _picked!.path));
      final response = await request.send();
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo uploaded successfully!')));
        
        // Strictly pop back within the /brand/... shell to avoid redirects
        context.pop(); 
      } else {
        throw Exception('Server responded with HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark
      appBar: AppBar(
        title: const Text('Upload Brand Asset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1E293B),
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.pop(), // Force safe shell back-nav
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: _picked == null
                  ? Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.add_a_photo, color: Color(0xFF6366F1)),
                        label: const Text('Tap to Choose Asset', style: TextStyle(color: Color(0xFF6366F1))),
                        onPressed: _pickImage,
                      ),
                    )
                  : const Center(
                      child: Text('Image Selected Successfully', style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _brandIdController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Brand ID',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF6366F1)), borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _productIdController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Product ID (Optional)',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF6366F1)), borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1), // Indigo
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isUploading ? null : _submit,
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Complete Upload', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
