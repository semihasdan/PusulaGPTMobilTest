import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/language_provider.dart';
import '../widgets/landing_app_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/ai_models_section.dart';
import '../widgets/screenshots_section.dart';
import '../widgets/benefits_section.dart';
import '../widgets/faq_section.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: LandingAppBar(
        onLanguageChanged: (languageCode) {
          ref.read(languageProvider.notifier).changeLanguage(languageCode);
        },
        onLoginPressed: () => context.go('/login'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(),
            SizedBox(height: 80),
            AiModelsSection(),
            SizedBox(height: 80),
            ScreenshotsSection(),
            SizedBox(height: 80),
            BenefitsSection(),
            SizedBox(height: 80),
            FaqSection(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}