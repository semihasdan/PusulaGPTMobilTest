import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/chat_provider.dart';
import '../../../../core/theme/app_theme.dart';

class ChatHistoryDrawer extends ConsumerWidget {
  const ChatHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatHistory = ref.watch(chatHistoryProvider);

    return Drawer(
      backgroundColor: AppTheme.darkBg,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildChatHistory(chatHistory),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.history,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Chat History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Previous conversations',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHistory(List chatHistory) {
    if (chatHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: AppTheme.mediumText,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'No chat history yet',
              style: TextStyle(
                color: AppTheme.mediumText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chatHistory.length,
      itemBuilder: (context, index) {
        final session = chatHistory[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
            ),
            title: Text(
              session.title,
              style: const TextStyle(
                color: AppTheme.lightText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              session.formattedDate,
              style: const TextStyle(
                color: AppTheme.mediumText,
                fontSize: 12,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: AppTheme.mediumText,
                size: 20,
              ),
              onPressed: () {
                // TODO: Show options menu (delete, rename, etc.)
              },
            ),
            onTap: () {
              // TODO: Load chat session
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.mediumText.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Start new chat
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.add,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              label: const Text(
                'New Chat',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}