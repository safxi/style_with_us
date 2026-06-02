import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _service = SupabaseService();

  void _save() async {
    final user = _service.currentUser;
    if (user == null) return;
    final payload = {
      'name': _name.text.trim(),
      'age': int.tryParse(_age.text) ?? 0,
      'weight': double.tryParse(_weight.text) ?? 0.0,
      'height': double.tryParse(_height.text) ?? 0.0,
    };
    final ok = await _service.upsertProfile(user.id, payload);
    if (ok) {
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full name')),
          TextField(controller: _age, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
          TextField(controller: _weight, decoration: const InputDecoration(labelText: 'Weight (kg)'), keyboardType: TextInputType.number),
          TextField(controller: _height, decoration: const InputDecoration(labelText: 'Height (cm)'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ]),
      ),
    );
  }
}
