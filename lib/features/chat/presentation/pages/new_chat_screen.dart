import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/chat_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/new_chat_drawer.dart';
import '../widgets/new_chat_header.dart';
import '../widgets/new_chat_message_area.dart';
import '../widgets/new_chat_input_area.dart';
import '../widgets/model_selector_sheet.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
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
      // Clear the controller immediately to ensure UI responsiveness
      _messageController.clear();
      
      // Send the message
      ref.read(chatProvider.notifier).sendMessage(message);
      
      // Scroll to bottom after a short delay to ensure message is rendered
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
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
  }

  void _showModelSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ModelSelectorSheet(),
    );
  }

  void _showLanguageDialog() {
    final localizations = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: Text(localizations.languageSettings),
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
            ListTile(
              title: const Text('العربية'),
              onTap: () {
                ref.read(languageProvider.notifier).changeLanguage('ar');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Русский'),
              onTap: () {
                ref.read(languageProvider.notifier).changeLanguage('ru');
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

    // Auto-scroll when new messages are added or typing state changes
    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous != null) {
        // Scroll when new messages are added
        if (previous.messages.length < next.messages.length) {
          Future.delayed(const Duration(milliseconds: 200), () {
            _scrollToBottom();
          });
        }
        // Scroll when typing indicator appears or disappears
        else if (previous.isAiTyping != next.isAiTyping) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _scrollToBottom();
          });
        }
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      resizeToAvoidBottomInset: true,
      drawer: NewChatDrawer(
        onLanguageSettings: _showLanguageDialog,
        onLogout: _logout,
      ),
      body: Column(
        children: [
          NewChatHeader(onModelSelectorTap: _showModelSelector),
          Expanded(
            child: NewChatMessageArea(
              messages: chatState.messages,
              scrollController: _scrollController,
              isAiTyping: chatState.isAiTyping,
            ),
          ),
          NewChatInputArea(
            controller: _messageController,
            onSend: _sendMessage,
            isLoading: chatState.isLoading,
          ),
        ],
      ),
    );
  }
}