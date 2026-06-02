import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  dynamic get currentUser => _client.auth.currentUser;

  Stream<dynamic> authStateChanges() => _client.auth.onAuthStateChange.map((e) => _client.auth.currentUser);

  Future<dynamic> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final res = await _client.auth.signUp(email: email, password: password);
    final user = res.user;
    if (user != null) {
      await _client.from('users').insert({
        'id': user.id,
        'name': name,
        'email': email,
        'role': role,
        'brandId': null,
        'preferences': <String, dynamic>{},
      });
    }
    return user;
  }

  Future<dynamic> login({required String email, required String password}) async {
    _cachedRole = null;
    _cachedBrandId = null;
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    return res.user;
  }

  Future<void> logout() async {
    _cachedRole = null;
    _cachedBrandId = null;
    await _client.auth.signOut();
  }

  String? _cachedRole;

  Future<String> getCurrentUserRole() async {
    if (_cachedRole != null) return _cachedRole!;
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');
    final res = await _client.from('users').select('role,brandId').eq('id', user.id).single();
    if (res == null) throw Exception('Failed to fetch role');
    final data = res is Map<String, dynamic> ? res : (res as Map?)?.cast<String, dynamic>() ?? {};
    final role = (data['role'] as String?)?.toLowerCase().trim();
    final result = (role == null || role.isEmpty) ? 'user' : role;
    _cachedRole = result;
    _cachedBrandId = (data['brandId'] as int?);
    return result;
  }

  int? _cachedBrandId;
  int? get currentBrandId => _cachedBrandId;

  String? get currentRole => _cachedRole;
}

