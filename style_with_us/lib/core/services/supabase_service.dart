import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<dynamic> signUpWithEmail(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<dynamic> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final res = await _client.from('profiles').select().eq('id', userId).single();
    if (res == null) return null;
    if (res is Map<String, dynamic>) return res;
    return (res as Map?)?.cast<String, dynamic>();
  }

  Future<bool> upsertProfile(String userId, Map<String, dynamic> payload) async {
    final res = await _client.from('profiles').upsert({
      'id': userId,
      ...payload,
    });
    return res != null;
  }
}
