import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/theme/app_theme.dart';
import 'chat_message_bubble.dart';
import 'typing_indicator.dart';

class NewChatMessageArea extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final bool isAiTyping;

  const NewChatMessageArea({
    super.key,
    required this.messages,
    required this.scrollController,
    this.isAiTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (messages.isEmpty) {
      return _buildWelcomeMessage(context, localizations);
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent, // ✅ Make transparent to show animated background
      ),
      child: ListView.builder(
        controller: scrollController,
        // ✅ Add proper padding to prevent occlusion by floating elements
        padding: const EdgeInsets.only(
          top: 24,    // ✅ Extra space below floating header
          bottom: 24, // ✅ Extra space above floating input area
          left: 16,
          right: 16,
        ),
        itemCount: messages.length + (isAiTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < messages.length) {
            final message = messages[index];
            return ChatMessageBubble(message: message);
          } else {
            // Show typing indicator at the end
            return const TypingIndicator();
          }
        },
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context, AppLocalizations localizations) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent, // ✅ Transparent to show animated background
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Glassmorphic welcome card
            Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localizations.helloUser.replaceAll('{email}', 'user@example.com'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.lightText,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.howCanHelp,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.mediumText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}