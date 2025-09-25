import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/chat_provider.dart';
import '../../../../core/widgets/pagination_loading_indicator.dart';
import 'user_prompt_item.dart';
import 'ai_response_item.dart';
import 'typing_indicator.dart';

class NewChatMessageArea extends ConsumerStatefulWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final bool isAiTyping;
  final bool isLoadingInitialMessages;
  final bool isLoadingMoreMessages;
  final bool hasReachedEndOfHistory;

  const NewChatMessageArea({
    super.key,
    required this.messages,
    required this.scrollController,
    this.isAiTyping = false,
    this.isLoadingInitialMessages = false,
    this.isLoadingMoreMessages = false,
    this.hasReachedEndOfHistory = false,
  });

  @override
  ConsumerState<NewChatMessageArea> createState() => _NewChatMessageAreaState();
}

class _NewChatMessageAreaState extends ConsumerState<NewChatMessageArea> {
  // ✅ Store the scroll offset before adding new messages
  double? _previousScrollOffset;
  // ✅ Store the max scroll extent before adding new messages
  double? _previousMaxScrollExtent;

  @override
  void initState() {
    super.initState();
    // ✅ Add scroll listener for pagination
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // ✅ Check if user has scrolled to the top (for reverse list)
    if (widget.scrollController.position.pixels >= 
        widget.scrollController.position.maxScrollExtent - 100) {
      // ✅ Load more messages when near the top
      if (!widget.isLoadingMoreMessages && !widget.hasReachedEndOfHistory) {
        // ✅ Store current scroll position before loading more messages
        _previousScrollOffset = widget.scrollController.position.pixels;
        _previousMaxScrollExtent = widget.scrollController.position.maxScrollExtent;
        ref.read(chatProvider.notifier).fetchMoreMessages();
      }
    }
  }

  @override
  void didUpdateWidget(covariant NewChatMessageArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // ✅ Adjust scroll position after new messages are loaded
    if (oldWidget.messages.length < widget.messages.length && 
        _previousScrollOffset != null && 
        _previousMaxScrollExtent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.scrollController.hasClients) {
          // ✅ Calculate the difference in maxScrollExtent to adjust scroll position
          final newMaxScrollExtent = widget.scrollController.position.maxScrollExtent;
          final scrollOffsetDelta = newMaxScrollExtent - _previousMaxScrollExtent!;
          
          // ✅ Adjust scroll position to maintain the same visual position
          final newScrollOffset = _previousScrollOffset! + scrollOffsetDelta;
          widget.scrollController.jumpTo(newScrollOffset.clamp(0.0, newMaxScrollExtent));
        }
      });
      _previousScrollOffset = null;
      _previousMaxScrollExtent = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // ✅ Show loading indicator while fetching initial messages
    if (widget.isLoadingInitialMessages) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: const Center(
          child: PaginationLoadingIndicator(
            message: 'Loading conversation...',
          ),
        ),
      );
    }

    // ✅ Show welcome message if no messages
    if (widget.messages.isEmpty) {
      return _buildWelcomeMessage(context, localizations);
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent, // ✅ Make transparent to show animated background
      ),
      child: ListView.builder(
        controller: widget.scrollController,
        reverse: true, // ✅ Critical: Start from bottom, build upwards
        // ✅ Add proper padding to prevent occlusion by floating elements
        padding: const EdgeInsets.only(
          top: 24,    // ✅ Space for pagination loading indicator
          bottom: 24, // ✅ Space above floating input area
          left: 16,
          right: 16,
        ),
        // ✅ Optimize performance with proper cache settings
        cacheExtent: 1000, // Cache more items for smoother scrolling
        itemCount: _getItemCount(),
        itemBuilder: (context, index) {
          // ✅ Handle pagination loading indicator at the top (index 0 in reverse list)
          if (widget.isLoadingMoreMessages && index == 0) {
            return const PaginationLoadingIndicator();
          }
          
          // ✅ Adjust index for pagination loading indicator
          final messageIndex = widget.isLoadingMoreMessages ? index - 1 : index;
          
          // ✅ Handle typing indicator (always at the bottom in reverse list - index 0)
          // ✅ For reverse list, typing indicator should be at index 0 when present
          if (widget.isAiTyping && index == 0) {
            return const TypingIndicator();
          }
          
          // ✅ Adjust message index if typing indicator is present
          final adjustedMessageIndex = widget.isAiTyping ? messageIndex - 1 : messageIndex;
          
          // ✅ Handle regular messages
          if (adjustedMessageIndex >= 0 && adjustedMessageIndex < widget.messages.length) {
            // ✅ Fix: Ensure we're accessing the correct message in the reversed list
            final message = widget.messages[widget.messages.length - 1 - adjustedMessageIndex];
            
            // ✅ Robust message type checking with null safety
            if (message.isUserMessage == true) {
              return UserPromptItem(
                key: ValueKey('user_${message.id}'),
                message: message,
              );
            } else if (message.isUserMessage == false) {
              return AIResponseItem(
                key: ValueKey('ai_${message.id}'),
                message: message,
              );
            } else {
              // ✅ Fallback for any edge cases
              return Container(
                key: ValueKey('error_${message.id}'),
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: Invalid message type for message: "${message.content}"',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ✅ Calculate total item count including loading indicators
  int _getItemCount() {
    int count = widget.messages.length;
    
    if (widget.isLoadingMoreMessages) {
      count += 1; // Add pagination loading indicator
    }
    
    if (widget.isAiTyping) {
      count += 1; // Add typing indicator
    }
    
    return count;
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