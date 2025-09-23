import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/glass_card.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientText(
                localizations.heroTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 16),
              Text(
                localizations.heroSubtitle,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 24),
              Text(
                localizations.heroDescription,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
                maxLines: 3,
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: GradientButton(
                      text: localizations.startFreeTrial,
                      hasGlow: true,
                      onPressed: () => context.go('/register'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassCard(
                      onTap: () {
                        // Scroll to learn more section
                      },
                      child: Center(
                        child: Text(
                          localizations.learnMore,
                          style: const TextStyle(
                            color: AppTheme.lightText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}