import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/chat_provider.dart';
import '../../../../core/theme/app_theme.dart';

class NewChatDrawer extends ConsumerWidget {
  final VoidCallback onLanguageSettings;
  final VoidCallback onLogout;

  const NewChatDrawer({
    super.key,
    required this.onLanguageSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedModel = ref.watch(selectedModelProvider);
    final conversations = ref.watch(conversationsProvider);
    final activeConversationId = ref.watch(activeConversationProvider);
    final localizations = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: AppTheme.darkBg,
      child: Column(
        children: [
          _buildHeader(context, selectedModel, localizations),
          _buildNewChatButton(context, localizations, ref),
          Expanded(
            child: _buildConversationHistory(conversations, activeConversationId, localizations, ref),
          ),
          _buildUserProfile(context, localizations),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, selectedModel, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        children: [
          // Model Logo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.mediumText.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                selectedModel.logoPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to gradient container with letter
                  return Container(
                    decoration: BoxDecoration(
                      gradient: _getModelGradient(selectedModel.id),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        selectedModel.name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            selectedModel.name,
            style: const TextStyle(
              color: AppTheme.lightText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // User tags
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              _buildTag(localizations.administrator, AppTheme.primaryBlue),
              _buildTag(localizations.premium, AppTheme.accentPurple),
              _buildTag(localizations.unlimited, AppTheme.emerald),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewChatButton(BuildContext context, AppLocalizations localizations, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // Start new chat
            ref.read(chatProvider.notifier).clearMessages();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            localizations.newChat,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationHistory(List conversations, String? activeConversationId, AppLocalizations localizations, WidgetRef ref) {
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: AppTheme.mediumText.withOpacity(0.5),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(
                color: AppTheme.mediumText.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        final isActive = conversation.id == activeConversationId;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryBlue.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
            border: isActive ? Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)) : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text(
              conversation.title,
              style: TextStyle(
                color: isActive ? AppTheme.primaryBlue : AppTheme.lightText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              timeago.format(conversation.timestamp),
              style: TextStyle(
                color: AppTheme.mediumText.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            onTap: () {
              // Load conversation
              ref.read(chatProvider.notifier).loadConversation(conversation.id);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Widget _buildUserProfile(BuildContext context, AppLocalizations localizations) {
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'user@example.com', // TODO: Get from auth state
                  style: TextStyle(
                    color: AppTheme.lightText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  localizations.administrator,
                  style: TextStyle(
                    color: AppTheme.mediumText.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: AppTheme.mediumText,
              size: 20,
            ),
            color: AppTheme.darkCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings, color: AppTheme.lightText, size: 18),
                    const SizedBox(width: 12),
                    Text(localizations.settings),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'language',
                child: Row(
                  children: [
                    const Icon(Icons.language, color: AppTheme.lightText, size: 18),
                    const SizedBox(width: 12),
                    Text(localizations.languageSettings),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: AppTheme.rose, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      localizations.logOut,
                      style: const TextStyle(color: AppTheme.rose),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  // TODO: Open settings
                  break;
                case 'language':
                  onLanguageSettings();
                  break;
                case 'logout':
                  onLogout();
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  LinearGradient _getModelGradient(String modelId) {
    switch (modelId) {
      case 'pusula':
        return AppTheme.primaryGradient;
      case 'comed':
        return const LinearGradient(
          colors: [AppTheme.emerald, AppTheme.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'diabet':
        return const LinearGradient(
          colors: [AppTheme.rose, AppTheme.accentPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppTheme.primaryGradient;
    }
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}