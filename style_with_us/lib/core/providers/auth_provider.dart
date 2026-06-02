import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

/// Stream of the raw auth user state (Supabase)
final authUserProvider = StreamProvider<dynamic>((ref) {
  return AuthService.instance.authStateChanges();
});

/// Asynchronously fetches the user's role from the backend once logged in.
final userRoleProvider = FutureProvider<String?>((ref) async {
  final user = await ref.watch(authUserProvider.future);
  if (user == null) return null;
  return await AuthService.instance.getCurrentUserRole();
});
