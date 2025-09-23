import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/glass_back_button.dart';
import '../widgets/animated_background.dart';
import '../widgets/auth_form_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.go('/chat');
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.rose,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const AnimatedBackground(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            'P',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        localizations.login,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 48),
                      // Email field
                      AuthFormField(
                        controller: _emailController,
                        labelText: localizations.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Invalid email format';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password field
                      AuthFormField(
                        controller: _passwordController,
                        labelText: localizations.password,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password
                          },
                          child: Text(
                            localizations.forgotPassword,
                            style: const TextStyle(color: AppTheme.primaryBlue),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Login button
                      GradientButton(
                        text: localizations.login,
                        width: double.infinity,
                        isLoading: authState.isLoading,
                        hasGlow: true,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ref.read(authProvider.notifier).login(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            localizations.dontHaveAccount,
                            style: const TextStyle(color: AppTheme.mediumText),
                          ),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: Text(
                              localizations.signUp,
                              style: const TextStyle(color: AppTheme.primaryBlue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Glass back button
            const Positioned(
              top: 16,
              left: 16,
              child: GlassBackButton(),
            ),
          ],
        ),
      ),
    );
  }
}