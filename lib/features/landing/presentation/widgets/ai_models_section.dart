import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_text.dart';

class AiModelsSection extends StatefulWidget {
  const AiModelsSection({super.key});

  @override
  State<AiModelsSection> createState() => _AiModelsSectionState();
}

class _AiModelsSectionState extends State<AiModelsSection> {
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final models = [
      {
        'title': localizations.pusulaGpt,
        'description': localizations.pusulaDescription,
        'logo': 'assets/logo/pusula_logo.png',
      },
      {
        'title': localizations.comedGpt,
        'description': localizations.comedDescription,
        'logo': 'assets/logo/comed_logo.png',
      },
      {
        'title': localizations.medDiabet,
        'description': localizations.diabetDescription,
        'logo': 'assets/logo/med_diyabet_logo.png',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          GradientText(
            'AI Models',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 48),
          // Vertically stacked model cards using Column
          Column(
            children: models
                .asMap()
                .entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: _buildModelCard(entry.value, entry.key),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModelCard(Map<String, dynamic> model, int index) {
    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _hoveredIndex = index),
        onTapUp: (_) => setState(() => _hoveredIndex = -1),
        onTapCancel: () => setState(() => _hoveredIndex = -1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2025), // Dark solid background
            borderRadius: BorderRadius.circular(20.0), // Soft rounded corners
            border: Border.all(
              color: AppTheme.mediumText.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo with bottom padding
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Image.asset(
                  model['logo'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to a simple icon if logo fails to load
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.smart_toy,
                        color: AppTheme.lightText,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
              // Model name - bold and bright white
              Text(
                model['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Model description - normal weight and dimmer color
              Text(
                model['description'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
            .animate(target: isHovered ? 1 : 0)
            .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02))
            .moveY(begin: 0, end: -4),
      ),
    );
  }


}