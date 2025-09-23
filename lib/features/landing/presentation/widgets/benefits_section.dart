import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final benefits = [
      {
        'icon': Icons.speed,
        'title': localizations.fastAccurate,
        'description': localizations.fastAccurateDesc,
      },
      {
        'icon': Icons.security,
        'title': localizations.securePrivate,
        'description': localizations.securePrivateDesc,
      },
      {
        'icon': Icons.integration_instructions,
        'title': localizations.easyIntegration,
        'description': localizations.easyIntegrationDesc,
      },
      {
        'icon': Icons.support_agent,
        'title': localizations.support247,
        'description': localizations.support247Desc,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            localizations.benefitsTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 48),
          Column(
            children: benefits
                .asMap()
                .entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildBenefitCard(entry.value, entry.key),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(Map<String, dynamic> benefit, int index) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              benefit['icon'],
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit['title'],
                  style: const TextStyle(
                    color: AppTheme.lightText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  benefit['description'],
                  style: const TextStyle(
                    color: AppTheme.mediumText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 600.ms)
        .slideX(begin: -0.2, end: 0);
  }
}