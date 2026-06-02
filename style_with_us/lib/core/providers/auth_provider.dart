import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Stream of the raw Firebase User auth state
final firebaseUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Asynchronously fetches the user's role from the backend/Firestore once logged in.
/// This acts as a strict blocker until the role is resolved, preventing unauthorized flashes.
final userRoleProvider = FutureProvider<String?>((ref) async {
  final user = await ref.watch(firebaseUserProvider.future);
  if (user == null) {
    return null; // Force logout redirect
  }
  return await AuthService.instance.getCurrentUserRole(); 
});
