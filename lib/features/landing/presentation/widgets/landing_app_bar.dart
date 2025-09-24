import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/theme/app_theme.dart';

class LandingAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Function(String) onLanguageChanged;
  final VoidCallback onLoginPressed;

  const LandingAppBar({
    super.key,
    required this.onLanguageChanged,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final localizations = AppLocalizations.of(context)!;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: AppTheme.darkCard.withOpacity(0.3),
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/logo/psl-logo.png', // Updated to use official logo
                    fit: BoxFit.contain, // Changed to contain to preserve logo aspect ratio
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to gradient container
                      return Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'P',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                localizations.appTitle,
                style: const TextStyle(
                  color: AppTheme.lightText,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            DropdownButton<String>(
              value: currentLocale.languageCode,
              underline: const SizedBox(),
              dropdownColor: AppTheme.darkCard,
              style: const TextStyle(color: AppTheme.lightText),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('EN')),
                DropdownMenuItem(value: 'tr', child: Text('TR')),
                DropdownMenuItem(value: 'ar', child: Text('AR')),
                DropdownMenuItem(value: 'ru', child: Text('RU')),
              ],
              onChanged: (value) {
                if (value != null) {
                  onLanguageChanged(value);
                }
              },
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: onLoginPressed,
              child: Text(
                localizations.login,
                style: const TextStyle(color: AppTheme.lightText),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}