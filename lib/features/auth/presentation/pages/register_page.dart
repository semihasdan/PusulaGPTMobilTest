import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/user_data.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/glass_back_button.dart';
import '../widgets/animated_background.dart';
import '../widgets/auth_form_field.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _organizationController = TextEditingController();
  final _referenceController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _organizationController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please check your email.'),
            backgroundColor: AppTheme.emerald,
          ),
        );
        context.go('/login');
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
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(), // ✅ Modern, platform-consistent scrolling
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Why Register section
                  _buildWhyRegisterSection(localizations),
                  const SizedBox(height: 32),
                  // Registration form
                  _buildRegistrationForm(localizations, authState),
                  const SizedBox(height: 24), // ✅ Add bottom padding for better UX
                ],
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

  Widget _buildWhyRegisterSection(AppLocalizations localizations) {
    final features = [
      {
        'icon': Icons.medical_services,
        'title': 'Advanced AI Models',
        'description': 'Access to specialized medical AI assistants',
      },
      {
        'icon': Icons.analytics,
        'title': 'Analytics Dashboard',
        'description': 'Comprehensive insights and reporting',
      },
      {
        'icon': Icons.cloud_sync,
        'title': 'Cloud Integration',
        'description': 'Seamless data synchronization',
      },
      {
        'icon': Icons.support,
        'title': 'Priority Support',
        'description': '24/7 dedicated customer support',
      },
    ];

    // ✅ Responsive layout based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 400 ? 1 : 2; // Single column on very small screens
    final childAspectRatio = screenWidth < 400 ? 2.5 : 1.0; // Wider cards on single column

    return Column(
      children: [
        Text(
          localizations.whyRegister,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(12.0), // Add padding to prevent edge overflow
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36, // Slightly smaller icon container
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: Colors.white,
                        size: 18, // Slightly smaller icon
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        color: AppTheme.lightText,
                        fontSize: 13, // Slightly smaller font
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2, // Allow title to wrap if needed
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Flexible( // ✅ KEY FIX: Make description flexible
                      child: Text(
                        feature['description'] as String,
                        style: const TextStyle(
                          color: AppTheme.mediumText,
                          fontSize: 11, // Smaller font for description
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3, // Allow more lines for description
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(AppLocalizations localizations, AuthState authState) {
    return GlassCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              localizations.register,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AuthFormField(
              controller: _fullNameController,
              labelText: localizations.fullName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Full name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            AuthFormField(
              controller: _organizationController,
              labelText: localizations.organizationName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Organization name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthFormField(
              controller: _referenceController,
              labelText: localizations.reference,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: localizations.sendRegistrationRequest,
              width: double.infinity,
              isLoading: authState.isLoading,
              hasGlow: true,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final userData = UserData(
                    fullName: _fullNameController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                    organizationName: _organizationController.text,
                    reference: _referenceController.text.isNotEmpty
                        ? _referenceController.text
                        : null,
                  );
                  ref.read(authProvider.notifier).register(userData);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  localizations.alreadyHaveAccount,
                  style: const TextStyle(color: AppTheme.mediumText),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    localizations.login,
                    style: const TextStyle(color: AppTheme.primaryBlue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}