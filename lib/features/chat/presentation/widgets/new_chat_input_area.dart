import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glassmorphic_container.dart';

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

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0), // ✅ Reduced padding to move closer to bottom
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ Ensure minimal height
          children: [
            // ✅ Glassmorphic input container
            GlassmorphicContainer(
              borderRadius: 30.0, // ✅ Capsule shape
              blurIntensity: 15.0,
              backgroundColor: Colors.black.withOpacity(0.25), // ✅ Glassmorphism effect
              borderColor: Colors.white.withOpacity(0.15),
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
                        color: AppTheme.lightText,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Herhangi bir şey sorun...', // ✅ Turkish placeholder
                        hintStyle: TextStyle(
                          color: AppTheme.mediumText.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        border: InputBorder.none, // ✅ Remove default underlines
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  // ✅ Circular gradient send button (retains vibrant background)
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
                              : AppTheme.primaryGradient, // ✅ Vibrant gradient stands out
                          color: isLoading 
                              ? AppTheme.mediumText.withOpacity(0.3)
                              : null,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isLoading 
                                  ? Colors.transparent
                                  : AppTheme.primaryBlue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
            const SizedBox(height: 6), // ✅ Reduced spacing
            // Disclaimer with glassmorphic background
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // ✅ Reduced padding
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                localizations.disclaimer,
                style: TextStyle(
                  color: AppTheme.mediumText.withOpacity(0.8),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}