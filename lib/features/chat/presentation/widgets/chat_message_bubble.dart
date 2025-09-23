import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/theme/app_theme.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isLoading) {
      return _buildLoadingBubble();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUserMessage 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUserMessage) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUserMessage 
                    ? AppTheme.primaryBlue 
                    : AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUserMessage 
                      ? const Radius.circular(16) 
                      : const Radius.circular(4),
                  bottomRight: message.isUserMessage 
                      ? const Radius.circular(4) 
                      : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.isUserMessage 
                      ? Colors.white 
                      : AppTheme.lightText,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUserMessage) ...[
            const SizedBox(width: 8),
            _buildAvatar(isUser: true),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildAvatar({bool isUser = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? AppTheme.primaryBlue : AppTheme.accentPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppTheme.mediumText,
        borderRadius: BorderRadius.circular(4),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(
          delay: Duration(milliseconds: index * 200),
          duration: 600.ms,
        )
        .then()
        .fadeOut(duration: 600.ms);
  }
}