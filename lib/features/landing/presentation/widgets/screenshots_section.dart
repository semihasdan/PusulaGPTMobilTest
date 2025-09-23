import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';

class ScreenshotsSection extends StatefulWidget {
  const ScreenshotsSection({super.key});

  @override
  State<ScreenshotsSection> createState() => _ScreenshotsSectionState();
}

class _ScreenshotsSectionState extends State<ScreenshotsSection> {
  int _selectedIndex = 0;

  List<Map<String, String>> _getScreenshots(AppLocalizations localizations) {
    return [
      {
        'title': localizations.pusulaInterface,
        'description': localizations.pusulaInterfaceDesc,
        'image': 'assets/images/pusula_screenshot.png',
      },
      {
        'title': localizations.comedDashboard,
        'description': localizations.comedDashboardDesc,
        'image': 'assets/images/comed_screenshot.png',
      },
      {
        'title': localizations.diabetAnalytics,
        'description': localizations.diabetAnalyticsDesc,
        'image': 'assets/images/diabet_screenshot.png',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            localizations.screenshotsTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 48),
          // Main image display
          GlassCard(
            height: 300,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppTheme.backgroundGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 80,
                      color: AppTheme.mediumText.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getScreenshots(localizations)[_selectedIndex]['title']!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getScreenshots(localizations)[_selectedIndex]['description']!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate(key: ValueKey(_selectedIndex))
              .fadeIn(duration: 300.ms),
          const SizedBox(height: 24),
          // Screenshot selector cards
          Row(
            children: _getScreenshots(localizations)
                .asMap()
                .entries
                .map((entry) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildSelectorCard(entry.value, entry.key),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorCard(Map<String, String> screenshot, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: GlassCard(
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              screenshot['title']!,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : AppTheme.lightText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}