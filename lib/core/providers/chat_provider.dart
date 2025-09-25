import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:async';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/conversation.dart';
import '../models/ai_model.dart';
import '../repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final selectedModelProvider = StateNotifierProvider<SelectedModelNotifier, AiModel>((ref) {
  return SelectedModelNotifier(ref);
});

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});

final conversationsProvider = StateNotifierProvider<ConversationsNotifier, List<Conversation>>((ref) {
  return ConversationsNotifier();
});

final activeConversationProvider = StateNotifierProvider<ActiveConversationNotifier, String?>((ref) {
  return ActiveConversationNotifier();
});

final chatHistoryProvider = StateNotifierProvider<ChatHistoryNotifier, List<ChatSession>>((ref) {
  return ChatHistoryNotifier();
});

class SelectedModelNotifier extends StateNotifier<AiModel> {
  final Ref _ref;
  
  SelectedModelNotifier(this._ref) : super(AiModel.availableModels.first);

  void selectModel(AiModel model) {
    state = model;
  }

  // ✅ Intelligent model switching with new chat creation
  void switchModel(AiModel newModel) {
    final currentModel = state;
    final activeConversationId = _ref.read(activeConversationProvider);
    
    // If switching models and there's an active conversation, create new chat
    if (newModel.id != currentModel.id && activeConversationId != null) {
      _ref.read(chatProvider.notifier).createNewChatWithModel(newModel);
    } else {
      // Just switch the model if no active conversation
      selectModel(newModel);
    }
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  // ✅ Add a flag to prevent duplicate pagination requests
  bool _isFetchingMoreMessages = false;

  ChatNotifier(this._ref) : super(const ChatState.initial());

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || !mounted) return;

    final chatRepository = _ref.read(chatRepositoryProvider);
    final selectedModel = _ref.read(selectedModelProvider);
    final activeConversationId = _ref.read(activeConversationProvider);
    final conversations = _ref.read(conversationsProvider);

    // Add user message and start AI typing
    final userMessage = ChatMessage.user(content.trim());
    final updatedMessages = [...state.messages, userMessage];
    
    if (!mounted) return;
    
    state = state.copyWith(
      messages: updatedMessages,
      isAiTyping: true,
      isLoading: true,
    );

    // ✅ Store user message in repository
    if (activeConversationId != null) {
      chatRepository.addMessage(activeConversationId, userMessage);
    }

    try {
      // Get AI response
      final response = await chatRepository.getMockResponse(content, selectedModel);
      final aiMessage = ChatMessage.ai(response);

      // Add AI response and stop typing
      final finalMessages = [...updatedMessages, aiMessage];
      
      if (!mounted) return;
      
      state = state.copyWith(
        messages: finalMessages,
        isAiTyping: false,
        isLoading: false,
      );

      // Update conversation in provider
      if (activeConversationId != null) {
        // ✅ Store AI message in repository
        chatRepository.addMessage(activeConversationId, aiMessage);
        
        final conversation = conversations.where((c) => c.id == activeConversationId).firstOrNull;
        if (conversation != null) {
          final updatedConversation = conversation.copyWith(
            messages: finalMessages,
            lastUpdated: DateTime.now(), // ✅ Update lastUpdated for recency sorting
          );
          _ref.read(conversationsProvider.notifier).updateConversation(activeConversationId, updatedConversation);
        }
      } else {
        // ✅ Create new conversation with current model
        final newConversation = Conversation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: content.length > 30 ? '${content.substring(0, 30)}...' : content,
          timestamp: DateTime.now(),
          lastUpdated: DateTime.now(),
          messages: finalMessages,
          modelUsed: selectedModel, // ✅ Track which model was used
        );
        // ✅ Store messages in repository for new conversation
        chatRepository.storeMessages(newConversation.id, finalMessages);
        _ref.read(conversationsProvider.notifier).addConversation(newConversation);
        _ref.read(activeConversationProvider.notifier).setActiveConversation(newConversation.id);
      }
    } catch (e) {
      if (!mounted) return;
      
      // Remove typing indicator and show error
      final errorMessage = ChatMessage.ai('Sorry, I encountered an error. Please try again.');
      final finalMessages = [...updatedMessages, errorMessage];
      state = state.copyWith(
        messages: finalMessages,
        isAiTyping: false,
        isLoading: false,
        error: e.toString(),
      );
      
      // ✅ Store error message in repository
      if (activeConversationId != null) {
        chatRepository.addMessage(activeConversationId, errorMessage);
      }
    }
  }

  // ✅ Load initial messages for a conversation (pagination-aware)
  Future<void> loadConversation(String conversationId) async {
    if (!mounted) return;
    
    final conversations = _ref.read(conversationsProvider);
    final conversation = conversations.where((c) => c.id == conversationId).firstOrNull;
    
    if (conversation != null) {
      _ref.read(activeConversationProvider.notifier).setActiveConversation(conversationId);
      _ref.read(selectedModelProvider.notifier).selectModel(conversation.modelUsed);
      
      // ✅ Load initial messages with pagination
      await fetchInitialMessages(conversationId);
    }
  }

  // ✅ Fetch initial messages (most recent page)
  Future<void> fetchInitialMessages(String conversationId) async {
    if (!mounted) return;
    
    state = state.copyWith(
      isLoadingInitialMessages: true,
      messages: [],
      currentPage: 1,
      hasReachedEndOfHistory: false,
    );
    
    try {
      final chatRepository = _ref.read(chatRepositoryProvider);
      final initialMessages = await chatRepository.getMessages(
        conversationId,
        page: 1,
        limit: 20,
      );
      
      if (!mounted) return;
      
      state = state.copyWith(
        messages: initialMessages,
        isLoadingInitialMessages: false,
        hasReachedEndOfHistory: initialMessages.length < 20,
      );
    } catch (e) {
      if (!mounted) return;
      
      state = state.copyWith(
        isLoadingInitialMessages: false,
        error: e.toString(),
      );
    }
  }

  // ✅ Fetch more messages (older messages for pagination)
  Future<void> fetchMoreMessages() async {
    // ✅ Prevent duplicate requests with improved guarding
    if (!mounted || state.isLoadingMoreMessages || state.hasReachedEndOfHistory || _isFetchingMoreMessages) {
      return;
    }
    
    final activeConversationId = _ref.read(activeConversationProvider);
    if (activeConversationId == null) return;
    
    // ✅ Set the flag to prevent duplicate requests
    _isFetchingMoreMessages = true;
    state = state.copyWith(isLoadingMoreMessages: true);
    
    try {
      final chatRepository = _ref.read(chatRepositoryProvider);
      final nextPage = state.currentPage + 1;
      
      final moreMessages = await chatRepository.getMessages(
        activeConversationId,
        page: nextPage,
        limit: 20,
      );
      
      if (!mounted) {
        _isFetchingMoreMessages = false;
        return;
      }
      
      // ✅ Validate messages to prevent any invalid content
      final validMessages = moreMessages.where((message) {
        // ✅ Ensure message has valid content
        return message.content.isNotEmpty && message.id.isNotEmpty;
      }).toList();
      
      if (moreMessages.isEmpty) {
        // Reached end of history
        state = state.copyWith(
          isLoadingMoreMessages: false,
          hasReachedEndOfHistory: true,
        );
      } else {
        // Append older messages to the end of the list (they're already in reverse order)
        final updatedMessages = [...state.messages, ...validMessages];
        
        state = state.copyWith(
          messages: updatedMessages,
          isLoadingMoreMessages: false,
          currentPage: nextPage,
        );
      }
    } on SocketException catch (e) {
      // Handle network errors specifically
      if (!mounted) {
        _isFetchingMoreMessages = false;
        return;
      }
      
      state = state.copyWith(
        isLoadingMoreMessages: false,
        error: 'Network error: Please check your connection and try again',
      );
    } on TimeoutException catch (e) {
      // Handle timeout errors
      if (!mounted) {
        _isFetchingMoreMessages = false;
        return;
      }
      
      state = state.copyWith(
        isLoadingMoreMessages: false,
        error: 'Request timeout: Please try again',
      );
    } catch (e) {
      // Handle all other errors
      if (!mounted) {
        _isFetchingMoreMessages = false;
        return;
      }
      
      state = state.copyWith(
        isLoadingMoreMessages: false,
        error: 'An error occurred: ${e.toString()}',
      );
    } finally {
      // ✅ Always reset the flag
      _isFetchingMoreMessages = false;
    }
  }

  // ✅ Create new chat when model is switched mid-conversation
  void createNewChatWithModel(AiModel newModel) {
    if (!mounted) return;
    
    // Clear current chat and set new model
    state = const ChatState.initial();
    _ref.read(activeConversationProvider.notifier).clearActiveConversation();
    _ref.read(selectedModelProvider.notifier).selectModel(newModel);
  }

  void clearMessages() {
    if (!mounted) return;
    
    state = const ChatState.initial();
    _ref.read(activeConversationProvider.notifier).clearActiveConversation();
  }

  // ✅ Update message feedback state
  void updateMessageFeedback(String messageId, FeedbackState feedbackState, {String? feedback}) {
    if (!mounted) return;
    
    final updatedMessages = state.messages.map((message) {
      if (message.id == messageId) {
        return message.copyWith(feedbackState: feedbackState);
      }
      return message;
    }).toList();
    
    state = state.copyWith(messages: updatedMessages);
    
    // Update conversation if active
    final activeConversationId = _ref.read(activeConversationProvider);
    if (activeConversationId != null) {
      final conversations = _ref.read(conversationsProvider);
      final conversation = conversations.where((c) => c.id == activeConversationId).firstOrNull;
      if (conversation != null) {
        final updatedConversation = conversation.copyWith(
          messages: updatedMessages,
          lastUpdated: DateTime.now(),
        );
        _ref.read(conversationsProvider.notifier).updateConversation(activeConversationId, updatedConversation);
      }
    }
  }

  // ✅ Regenerate AI response
  Future<void> regenerateResponse(String messageId) async {
    if (!mounted) return;
    
    final chatRepository = _ref.read(chatRepositoryProvider);
    final selectedModel = _ref.read(selectedModelProvider);
    
    // Find the message and get the previous user message
    final messageIndex = state.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1 || messageIndex == 0) return;
    
    final userMessage = state.messages[messageIndex - 1];
    if (userMessage.isUserMessage) {
      // Remove the old AI response and add loading state
      final messagesWithoutOldResponse = state.messages.take(messageIndex).toList();
      
      state = state.copyWith(
        messages: messagesWithoutOldResponse,
        isAiTyping: true,
        isLoading: true,
      );
      
      try {
        // Get new AI response
        final response = await chatRepository.getMockResponse(userMessage.content, selectedModel);
        final newAiMessage = ChatMessage.ai(response);
        
        final finalMessages = [...messagesWithoutOldResponse, newAiMessage];
        
        if (!mounted) return;
        
        state = state.copyWith(
          messages: finalMessages,
          isAiTyping: false,
          isLoading: false,
        );
        
        // Update conversation
        final activeConversationId = _ref.read(activeConversationProvider);
        if (activeConversationId != null) {
          final conversations = _ref.read(conversationsProvider);
          final conversation = conversations.where((c) => c.id == activeConversationId).firstOrNull;
          if (conversation != null) {
            final updatedConversation = conversation.copyWith(
              messages: finalMessages,
              lastUpdated: DateTime.now(),
            );
            _ref.read(conversationsProvider.notifier).updateConversation(activeConversationId, updatedConversation);
          }
        }
      } catch (e) {
        if (!mounted) return;
        
        state = state.copyWith(
          isAiTyping: false,
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }
}

class ConversationsNotifier extends StateNotifier<List<Conversation>> {
  // ✅ Start with empty list instead of mock data
  ConversationsNotifier() : super([]);

  void addConversation(Conversation conversation) {
    // ✅ Add and sort by recency
    final updatedList = [conversation, ...state];
    state = _sortByRecency(updatedList);
  }

  void updateConversation(String id, Conversation updatedConversation) {
    final updatedList = state.map((conv) => conv.id == id ? updatedConversation : conv).toList();
    // ✅ Re-sort after update to maintain recency order
    state = _sortByRecency(updatedList);
  }

  void removeConversation(String id) {
    state = state.where((conv) => conv.id != id).toList();
  }

  Conversation? getConversation(String id) {
    try {
      return state.firstWhere((conv) => conv.id == id);
    } catch (e) {
      return null;
    }
  }

  // ✅ Dynamic recency sorting - most recent first
  List<Conversation> _sortByRecency(List<Conversation> conversations) {
    final sorted = [...conversations];
    sorted.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return sorted;
  }

  // ✅ Getter for sorted conversations (always returns sorted list)
  List<Conversation> get sortedConversations => _sortByRecency(state);
}

class ActiveConversationNotifier extends StateNotifier<String?> {
  ActiveConversationNotifier() : super(null);

  void setActiveConversation(String? conversationId) {
    state = conversationId;
  }

  void clearActiveConversation() {
    state = null;
  }
}

class ChatHistoryNotifier extends StateNotifier<List<ChatSession>> {
  // ✅ Start with empty list instead of mock data
  ChatHistoryNotifier() : super([]);

  void addSession(ChatSession session) {
    state = [session, ...state];
  }

  void removeSession(String sessionId) {
    state = state.where((session) => session.id != sessionId).toList();
  }
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isAiTyping;
  final String? error;
  // ✅ New pagination-specific state properties
  final bool isLoadingInitialMessages;
  final bool isLoadingMoreMessages;
  final bool hasReachedEndOfHistory;
  final int currentPage;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isAiTyping = false,
    this.error,
    this.isLoadingInitialMessages = false,
    this.isLoadingMoreMessages = false,
    this.hasReachedEndOfHistory = false,
    this.currentPage = 1,
  });

  const ChatState.initial() : this(
    messages: const [],
    isLoading: false,
    isAiTyping: false,
    error: null,
    isLoadingInitialMessages: false,
    isLoadingMoreMessages: false,
    hasReachedEndOfHistory: false,
    currentPage: 1,
  );

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isAiTyping,
    String? error,
    bool? isLoadingInitialMessages,
    bool? isLoadingMoreMessages,
    bool? hasReachedEndOfHistory,
    int? currentPage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      error: error,
      isLoadingInitialMessages: isLoadingInitialMessages ?? this.isLoadingInitialMessages,
      isLoadingMoreMessages: isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      hasReachedEndOfHistory: hasReachedEndOfHistory ?? this.hasReachedEndOfHistory,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}