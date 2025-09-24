import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/theme/app_theme.dart';

class UserPromptItem extends StatelessWidget {
  final ChatMessage message;

  const UserPromptItem({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    // Get the screen width to constrain the bubble size
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Row(
        // ✅ 1. Align the content to the end (right side) of the Row.
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            // ✅ 2. Add constraints to prevent the bubble from being too wide.
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.75, // Max 75% of screen width
            ),
            // ✅ 3. Add decoration to create the semi-transparent bubble effect.
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), // Semi-transparent color
              borderRadius: const BorderRadius.only( // Custom border radius for a bubble look
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.zero,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              message.content ?? '', // Handle null content gracefully
              style: const TextStyle(
                color: AppTheme.lightText,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.3, end: 0);
  }
}