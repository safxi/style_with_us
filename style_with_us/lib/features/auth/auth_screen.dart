import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/style_tokens.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/glass_card.dart';

class AuthScreen extends ConsumerStatefulWidget {
  static const String routeName = 'auth';

  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  String _selectedRole = 'user'; // 'user', 'brand', or 'admin'

  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _onSubmit() async {
    final formKey = _isLogin ? _loginFormKey : _signupFormKey;
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (!_isLogin && !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept Terms & Conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await AuthService.instance.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await AuthService.instance.signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole,
        );
      }

      // update cached role (and provider) before navigation
      final role = await AuthService.instance.getCurrentUserRole();
      if (mounted) {
        // Riverpod's FutureProvider automatically listens to authStateChanges
        // No manual state override is required.
      }

      if (!mounted) return;
      switch (role) {
        case 'admin':
          context.go('/admin');
          break;
        case 'brand':
          context.go('/brand');
          break;
        default:
          context.go('/home');
      }
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF050816), const Color(0xFF0B1024)]
                : [primaryPurple.withOpacity(0.2), primaryPink.withOpacity(0.15)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: space24, vertical: space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    Column(
                      children: [
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: primaryGradient,
                            boxShadow: floatingShadow,
                          ),
                          child: const Icon(Icons.style, color: Colors.white),
                        )
                            .animate()
                            .scale(duration: 500.ms, curve: Curves.easeOutBack)
                            .shimmer(duration: 1200.ms, delay: 300.ms),
                        const SizedBox(height: space8),
                        Text(
                          'Style With Us',
                          style: h4.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: space32),
                Text(
                  'Welcome to Style With Us',
                  style: h2.copyWith(color: Colors.white),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                const SizedBox(height: space8),
                Text(
                  'Your AI fashion companion',
                  style: bodyMedium.copyWith(color: Colors.white70),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                const SizedBox(height: space24),

                GlassCard(
                  padding: const EdgeInsets.all(space16),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radiusLarge),
                          color: Colors.white.withOpacity(0.12),
                        ),
                        padding: const EdgeInsets.all(space4),
                        child: Row(
                          children: [
                            _SegmentTab(
                              label: 'Login',
                              isActive: _isLogin,
                              onTap: () {
                                if (!_isLogin) _toggleMode();
                              },
                            ),
                            _SegmentTab(
                              label: 'Sign Up',
                              isActive: !_isLogin,
                              onTap: () {
                                if (_isLogin) _toggleMode();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: space16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          const offset = Offset(0.1, 0);
                          final inAnimation =
                              Tween<Offset>(begin: offset, end: Offset.zero).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(position: inAnimation, child: child),
                          );
                        },
                        child: _isLogin ? _buildLoginForm() : _buildSignupForm(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: space8),
          Text('Email', style: bodySmall.copyWith(color: textSecondary)),
          const SizedBox(height: space4),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email_outlined),
              hintText: 'your@email.com',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email';
              if (!value.contains('@')) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: space16),
          Text('Password', style: bodySmall.copyWith(color: textSecondary)),
          const SizedBox(height: space4),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: 'Enter password',
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your password';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: space8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Forgot password flow not implemented yet')),
                );
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  color: primaryPurple,
                ),
              ),
            ),
          ),
          const SizedBox(height: space12),
          GradientButton(
            text: 'Login',
            isLoading: _isLoading,
            onPressed: _onSubmit,
          ),
          const SizedBox(height: space16),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: space8),
                child: Text('Or continue with', style: bodySmall),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: space12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: space12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radiusMedium),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: space12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.apple, size: 24),
                  label: const Text('Apple'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: space12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radiusMedium),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: space8),
          Text('Name', style: bodySmall.copyWith(color: textSecondary)),
          const SizedBox(height: space4),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline),
              hintText: 'Full name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your name';
              return null;
            },
          ),
          const SizedBox(height: space16),
          Text('Email', style: bodySmall.copyWith(color: textSecondary)),
          const SizedBox(height: space4),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email_outlined),
              hintText: 'your@email.com',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email';
              if (!value.contains('@')) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: space16),
          Text('Password', style: bodySmall.copyWith(color: textSecondary)),
          const SizedBox(height: space4),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: 'Enter password',
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your password';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: space16),
          Text('Confirm Password', style: bodySmall.copyWith(color: textSecondary)),
          const SizedBox(height: space4),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: 'Confirm password',
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please confirm your password';
              if (value != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: space16),
          Text('Select Account Type', style: bodySmall.copyWith(color: textSecondary)),
          const SizedBox(height: space8),
          Wrap(
            spacing: space8,
            children: [
              _RoleChip(
                label: 'User',
                value: 'user',
                groupValue: _selectedRole,
                onChanged: (v) => setState(() => _selectedRole = v),
              ),
              _RoleChip(
                label: 'Brand',
                value: 'brand',
                groupValue: _selectedRole,
                onChanged: (v) => setState(() => _selectedRole = v),
              ),
              _RoleChip(
                label: 'Admin',
                value: 'admin',
                groupValue: _selectedRole,
                onChanged: (v) => setState(() => _selectedRole = v),
              ),
            ],
          ),
          const SizedBox(height: space12),
          Row(
            children: [
              Checkbox(
                value: _acceptedTerms,
                onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Expanded(
                child: Text(
                  'I agree to Terms & Conditions',
                  style: bodySmall.copyWith(color: textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: space12),
          GradientButton(
            text: 'Sign Up',
            isLoading: _isLoading,
            onPressed: _onSubmit,
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: space12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radiusLarge),
            gradient: isActive ? primaryGradient : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _RoleChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onChanged(value),
      selectedColor: primaryPurple,
      labelStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isSelected ? Colors.white : textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        side: BorderSide(
          color: isSelected ? primaryPurple : primaryPurple.withOpacity(0.3),
        ),
      ),
      backgroundColor: surfaceColor,
    );
  }
}

