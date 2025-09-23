import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/chat_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/chat_history_drawer.dart';
import '../widgets/model_selector_sheet.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      ref.read(chatProvider.notifier).sendMessage(message);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showModelSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ModelSelectorSheet(),
    );
  }

  void _showProfileMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 200,
        kToolbarHeight,
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'language',
          child: Row(
            children: [
              const Icon(Icons.language, color: AppTheme.lightText),
              const SizedBox(width: 12),
              Text(
                'Language Settings',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person, color: AppTheme.lightText),
              const SizedBox(width: 12),
              Text(
                'Profile',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, color: AppTheme.rose),
              const SizedBox(width: 12),
              Text(
                'Log Out',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.rose,
                ),
              ),
            ],
          ),
        ),
      ],
      color: AppTheme.darkCard,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ).then((value) {
      switch (value) {
        case 'language':
          _showLanguageDialog();
          break;
        case 'profile':
          // TODO: Implement profile screen
          break;
        case 'logout':
          _logout();
          break;
      }
    });
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                ref.read(languageProvider.notifier).changeLanguage('en');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Türkçe'),
              onTap: () {
                ref.read(languageProvider.notifier).changeLanguage('tr');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    ref.read(authProvider.notifier).logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    // Auto-scroll when new messages are added
    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous != null && 
          previous.messages.length < next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: ChatAppBar(
        onModelSelectorTap: _showModelSelector,
        onProfileTap: _showProfileMenu,
      ),
      drawer: const ChatHistoryDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ChatMessageList(
              messages: chatState.messages,
              scrollController: _scrollController,
            ),
          ),
          ChatInputArea(
            controller: _messageController,
            onSend: _sendMessage,
            isLoading: chatState.isLoading,
          ),
        ],
      ),
    );
  }
}