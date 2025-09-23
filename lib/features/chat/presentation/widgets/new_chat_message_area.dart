import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/theme/app_theme.dart';
import 'chat_message_bubble.dart';

class NewChatMessageArea extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  const NewChatMessageArea({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (messages.isEmpty) {
      return _buildWelcomeMessage(context, localizations);
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkBg,
            Color(0xFF0F172A),
          ],
        ),
      ),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return ChatMessageBubble(message: message);
        },
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context, AppLocalizations localizations) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkBg,
            Color(0xFF0F172A),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              localizations.helloUser.replaceAll('{email}', 'user@example.com'), // TODO: Get from auth
              style: const TextStyle(
                color: AppTheme.lightText,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              localizations.howCanHelp,
              style: const TextStyle(
                color: AppTheme.mediumText,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}