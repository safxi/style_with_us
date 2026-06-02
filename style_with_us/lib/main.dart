import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/auth_screen.dart';
import 'features/profile/profile_setup_screen.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zdfgkiadtivpurwjbbqi.supabase.co',
    anonKey: 'sb_publishable_YJeAk2zEpkecnY0x63i8xg_gtXobzEM',
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _service = SupabaseService();

  @override
  Widget build(BuildContext context) {
    final user = _service.currentUser;
    if (user == null) {
      return const MaterialApp(home: AuthScreen());
    }
    return MaterialApp(
      home: Builder(builder: (context) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: _service.getProfile(user.id),
          builder: (context, snap) {
            if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
            final profile = snap.data;
            if (profile == null || profile['name'] == null) {
              return const ProfileSetupScreen();
            }
            return HomeScreen(profile: profile);
          },
        );
      }),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> profile;
  const HomeScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome, ${profile['name'] ?? 'User'}', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text('Age: ${profile['age'] ?? '-'}'),
          Text('Weight: ${profile['weight'] ?? '-'} kg'),
          Text('Height: ${profile['height'] ?? '-'} cm'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (!context.mounted) return;
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
          }, child: const Text('Sign out')),
        ]),
      ),
    );
  }
}

