import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/chat_provider.dart';
import '../../../../core/widgets/orbital_loading_animation.dart';

class NewChatInputArea extends ConsumerWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const NewChatInputArea({
    super.key,
    required this.controller,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final selectedModel = ref.watch(selectedModelProvider);

    // ✅ Generate localized placeholder text based on selected model
    String getPlaceholderText() {
      final locale = Localizations.localeOf(context).languageCode;
      
      switch (locale) {
        case 'en':
          return 'Ask ${selectedModel.name} anything...';
        case 'tr':
          return '${selectedModel.name}\'e sor...';
        case 'ar':
          return 'اسأل ${selectedModel.name} أي شيء...';
        case 'ru':
          return 'Спросите ${selectedModel.name} о чем угодно...';
        default:
          return 'Ask ${selectedModel.name} anything...';
      }
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 0.0), // ✅ Reduced padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Simple input container without glassmorphism
            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkCard, // ✅ Simple solid background
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(
                  color: AppTheme.mediumText.withOpacity(0.2),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: !isLoading,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: getPlaceholderText(), // ✅ Dynamic localized placeholder
                        hintStyle: TextStyle(
                          color: AppTheme.mediumText.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  // ✅ Circular gradient send button
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: isLoading ? null : onSend,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: isLoading 
                              ? null
                              : AppTheme.primaryGradient,
                          color: isLoading 
                              ? AppTheme.mediumText.withOpacity(0.3)
                              : null,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isLoading 
                                  ? Colors.transparent
                                  : AppTheme.primaryBlue.withOpacity(0.6),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isLoading
                            ? const OrbitalLoadingAnimation(
                                size: 44.0,
                                satelliteColor: Colors.white,
                                satelliteSize: 3.0,
                                duration: Duration(milliseconds: 1000),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // ✅ Simple disclaimer without background frame
            Text(
              localizations.disclaimer,
              style: TextStyle(
                color: AppTheme.mediumText.withOpacity(0.6),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}