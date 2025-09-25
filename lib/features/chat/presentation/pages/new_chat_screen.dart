import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/chat_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_gradient_background.dart';
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
          // ✅ For reverse list, scroll to position 0 (bottom)
          _scrollController.animateTo(
            0.0, // ✅ Bottom of reverse list
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
    // ✅ Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 600;

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
      resizeToAvoidBottomInset: true,
      drawer: NewChatDrawer(
        onLanguageSettings: _showModelSelector,
        onLogout: _logout,
      ),
      // ✅ Stack layout with floating glassmorphic elements
      body: Stack(
        children: [
          // ✅ Animated gradient background as base layer
          const AnimatedGradientBackground(),
          
          // ✅ Message area with pagination support
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: isLargeScreen ? 100 : 90,  // ✅ Responsive spacing for header
                bottom: isLargeScreen ? 140 : 130, // ✅ Responsive spacing for input
              ),
              child: NewChatMessageArea(
                messages: chatState.messages,
                scrollController: _scrollController,
                isAiTyping: chatState.isAiTyping,
                isLoadingInitialMessages: chatState.isLoadingInitialMessages,
                isLoadingMoreMessages: chatState.isLoadingMoreMessages,
                hasReachedEndOfHistory: chatState.hasReachedEndOfHistory,
              ),
            ),
          ),
          
          // ✅ Floating glassmorphic header at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NewChatHeader(
              onModelSelectorTap: _showModelSelector,
              // ✅ Responsive header sizing
              height: isLargeScreen ? 100 : 90,
            ),
          ),
          
          // ✅ Floating glassmorphic input area at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NewChatInputArea(
              controller: _messageController,
              onSend: _sendMessage,
              isLoading: chatState.isLoading,
              // ✅ Responsive input sizing
              height: isLargeScreen ? 140 : 130,
            ),
          ),
        ],
      ),
    );
  }
}