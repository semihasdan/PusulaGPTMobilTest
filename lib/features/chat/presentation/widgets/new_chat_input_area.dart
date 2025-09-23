import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

class NewChatInputArea extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        border: Border(
          top: BorderSide(
            color: AppTheme.mediumText.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Input container
            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.mediumText.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: !isLoading,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        color: AppTheme.lightText,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: localizations.askAnythingPlaceholder,
                        hintStyle: TextStyle(
                          color: AppTheme.mediumText.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: isLoading ? null : onSend,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isLoading 
                              ? AppTheme.mediumText.withOpacity(0.3) 
                              : AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.lightText,
                                      ),
                                    ),
                                  ),
                                ),
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
            const SizedBox(height: 12),
            // Disclaimer
            Text(
              localizations.disclaimer,
              style: TextStyle(
                color: AppTheme.mediumText.withOpacity(0.6),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}