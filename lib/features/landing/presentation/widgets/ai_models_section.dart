import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    final models = [
      {
        'title': localizations.pusulaGpt,
        'description': localizations.pusulaDescription,
        'icon': 'P',
        'color': '#020101ff',
        'background': 'assets/logo/pusula_logo.png',
      },
      {
        'title': localizations.comedGpt,
        'description': localizations.comedDescription,
        'icon': 'C',
        'color': AppTheme.emerald,
      },
      {
        'title': localizations.medDiabet,
        'description': localizations.diabetDescription,
        'icon': 'M',
        'color': AppTheme.rose,
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
          isSmallScreen
              ? Column(
                  children: models
                      .asMap()
                      .entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildModelCard(entry.value, entry.key),
                          ))
                      .toList(),
                )
              : Row(
                  children: models
                      .asMap()
                      .entries
                      .map((entry) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _buildModelCard(entry.value, entry.key),
                            ),
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
        child: GlassCard(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.mediumText.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    _getLogoPath(model['title']),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to gradient container with letter
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [model['color'], AppTheme.accentPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            model['icon'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                model['title'],
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                model['description'],
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
            .animate(target: isHovered ? 1 : 0)
            .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05))
            .moveY(begin: 0, end: -8),
      ),
    );
  }

  String _getLogoPath(String? title) {
    switch (title) {
      case 'PusulaGPT':
        return 'assets/logo/pusula_logo.png';
      case 'ComedGPT':
        return 'assets/logo/comed_logo.png';
      case 'MedDiabet':
        return 'assets/logo/med_diyabet_logo.png';
      default:
        return 'assets/logo/pusula_logo.png';
    }
  }
}