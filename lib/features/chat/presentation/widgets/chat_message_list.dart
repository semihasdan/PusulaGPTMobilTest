import 'package:flutter/material.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/theme/app_theme.dart';
import 'chat_message_bubble.dart';

class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return _buildEmptyState();
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

  Widget _buildEmptyState() {
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
            const SizedBox(height: 24),
            const Text(
              'Start a conversation',
              style: TextStyle(
                color: AppTheme.lightText,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ask me anything about your health',
              style: TextStyle(
                color: AppTheme.mediumText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}