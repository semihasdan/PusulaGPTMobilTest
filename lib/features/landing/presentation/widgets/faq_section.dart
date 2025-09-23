import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final faqs = [
      {
        'question': localizations.faqWhatIs,
        'answer': localizations.faqWhatIsAnswer,
      },
      {
        'question': localizations.faqSecurity,
        'answer': localizations.faqSecurityAnswer,
      },
      {
        'question': localizations.faqIntegration,
        'answer': localizations.faqIntegrationAnswer,
      },
      {
        'question': localizations.faqTrial,
        'answer': localizations.faqTrialAnswer,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            localizations.faqTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 48),
          Column(
            children: faqs
                .asMap()
                .entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildFaqItem(entry.value, entry.key),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(Map<String, String> faq, int index) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
          ),
        ),
        child: ExpansionTile(
          title: Text(
            faq['question']!,
            style: const TextStyle(
              color: AppTheme.lightText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconColor: AppTheme.primaryBlue,
          collapsedIconColor: AppTheme.mediumText,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq['answer']!,
                style: const TextStyle(
                  color: AppTheme.mediumText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }
}