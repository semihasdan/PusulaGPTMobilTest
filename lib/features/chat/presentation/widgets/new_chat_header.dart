import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/chat_provider.dart';
import '../../../../core/theme/app_theme.dart';

class NewChatHeader extends ConsumerWidget {
  final VoidCallback onModelSelectorTap;

  const NewChatHeader({
    super.key,
    required this.onModelSelectorTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedModel = ref.watch(selectedModelProvider);
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.mediumText.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Row - Main interactive row
            Row(
              children: [
                // Menu button
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: AppTheme.lightText),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const SizedBox(width: 8),
                // Model selector
                Expanded(
                  child: GestureDetector(
                    onTap: onModelSelectorTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.darkCard.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.mediumText.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedModel.displayName,
                              style: const TextStyle(
                                color: AppTheme.lightText,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppTheme.mediumText,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Spacer for balance
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 8),
            // Bottom Row - User tags with wrap support
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                _buildTag(localizations.administrator, AppTheme.primaryBlue),
                _buildTag(localizations.premium, AppTheme.accentPurple),
                _buildTag(localizations.unlimited, AppTheme.emerald),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}