import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference<Map<String, dynamic>> _usersRef =
      FirebaseFirestore.instance.collection('users');

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    await _usersRef.doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'role': role,
      'brandId': null,
      'createdAt': FieldValue.serverTimestamp(),
      'preferences': <String, dynamic>{},
    });

    return credential.user;
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    _cachedRole = null;
    _cachedBrandId = null;
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> logout() async {
    _cachedRole = null;
    _cachedBrandId = null;
    await _auth.signOut();
  }

  /// Returns the current user's role stored in Firestore.
  /// Defaults to `user` if the document or field is missing.
  String? _cachedRole;

  Future<String> getCurrentUserRole() async {
    if (_cachedRole != null) return _cachedRole!;
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final snapshot = await _usersRef
        .doc(user.uid)
        .get()
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Role fetch timed out. Check your connection.');
    });
    final data = snapshot.data() ?? <String, dynamic>{};
    final role = (data['role'] as String?)?.toLowerCase().trim();
    final result = (role == null || role.isEmpty) ? 'user' : role;
    _cachedRole = result;
    // also store brandId if present
    _cachedBrandId = data['brandId'] as int?;
    return result;
  }

  int? _cachedBrandId;
  int? get currentBrandId => _cachedBrandId;

  /// synchronous role (may be null until fetched once).
  String? get currentRole => _cachedRole;
}

