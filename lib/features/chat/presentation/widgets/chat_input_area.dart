import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const ChatInputArea({
    super.key,
    required this.controller,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: AppTheme.mediumText.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.darkBg.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.mediumText.withOpacity(0.3),
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
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        color: AppTheme.mediumText,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: isLoading 
                            ? null 
                            : AppTheme.primaryGradient,
                        color: isLoading 
                            ? AppTheme.mediumText.withOpacity(0.3) 
                            : null,
                        borderRadius: BorderRadius.circular(20),
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
        ),
      ),
    );
  }
}