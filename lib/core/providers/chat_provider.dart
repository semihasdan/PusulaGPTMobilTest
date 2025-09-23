import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/conversation.dart';
import '../models/ai_model.dart';
import '../repositories/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final selectedModelProvider = StateNotifierProvider<SelectedModelNotifier, AiModel>((ref) {
  return SelectedModelNotifier();
});

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  final selectedModel = ref.watch(selectedModelProvider);
  final activeConversationId = ref.watch(activeConversationProvider);
  final conversations = ref.watch(conversationsProvider);
  return ChatNotifier(chatRepository, selectedModel, activeConversationId, conversations, ref);
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
  SelectedModelNotifier() : super(AiModel.availableModels.first);

  void selectModel(AiModel model) {
    state = model;
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository;
  final AiModel _selectedModel;
  final String? _activeConversationId;
  final List<Conversation> _conversations;
  final Ref _ref;

  ChatNotifier(this._chatRepository, this._selectedModel, this._activeConversationId, this._conversations, this._ref) 
      : super(_getInitialState(_activeConversationId, _conversations));

  static ChatState _getInitialState(String? activeConversationId, List<Conversation> conversations) {
    if (activeConversationId != null) {
      final conversation = conversations.where((c) => c.id == activeConversationId).firstOrNull;
      if (conversation != null) {
        return ChatState(messages: conversation.messages);
      }
    }
    return const ChatState.initial();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage.user(content.trim());
    final updatedMessages = [...state.messages, userMessage];
    
    // Add loading indicator
    final loadingMessage = ChatMessage.loading();
    state = state.copyWith(
      messages: [...updatedMessages, loadingMessage],
      isLoading: true,
    );

    try {
      // Get AI response
      final response = await _chatRepository.getMockResponse(content, _selectedModel);
      final aiMessage = ChatMessage.ai(response);

      // Remove loading indicator and add AI response
      final finalMessages = [...updatedMessages, aiMessage];
      state = state.copyWith(
        messages: finalMessages,
        isLoading: false,
      );

      // Update conversation in provider
      if (_activeConversationId != null) {
        final conversation = _conversations.where((c) => c.id == _activeConversationId).firstOrNull;
        if (conversation != null) {
          final updatedConversation = conversation.copyWith(
            messages: finalMessages,
            timestamp: DateTime.now(),
          );
          _ref.read(conversationsProvider.notifier).updateConversation(_activeConversationId, updatedConversation);
        }
      } else {
        // Create new conversation
        final newConversation = Conversation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: content.length > 30 ? '${content.substring(0, 30)}...' : content,
          timestamp: DateTime.now(),
          messages: finalMessages,
        );
        _ref.read(conversationsProvider.notifier).addConversation(newConversation);
        _ref.read(activeConversationProvider.notifier).setActiveConversation(newConversation.id);
      }
    } catch (e) {
      // Remove loading indicator and show error
      final errorMessage = ChatMessage.ai('Sorry, I encountered an error. Please try again.');
      final finalMessages = [...updatedMessages, errorMessage];
      state = state.copyWith(
        messages: finalMessages,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void loadConversation(String conversationId) {
    final conversation = _conversations.where((c) => c.id == conversationId).firstOrNull;
    if (conversation != null) {
      state = ChatState(messages: conversation.messages);
      _ref.read(activeConversationProvider.notifier).setActiveConversation(conversationId);
    }
  }

  void clearMessages() {
    state = const ChatState.initial();
    _ref.read(activeConversationProvider.notifier).clearActiveConversation();
  }
}

class ConversationsNotifier extends StateNotifier<List<Conversation>> {
  ConversationsNotifier() : super(_mockConversations);

  void addConversation(Conversation conversation) {
    state = [conversation, ...state];
  }

  void updateConversation(String id, Conversation updatedConversation) {
    state = state.map((conv) => conv.id == id ? updatedConversation : conv).toList();
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

  static final List<Conversation> _mockConversations = [
    Conversation(
      id: '1',
      title: 'General Health Consultation',
      timestamp: DateTime.now().subtract(const Duration(hours: 21)),
      messages: [],
    ),
    Conversation(
      id: '2',
      title: 'Diabetes Management',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      messages: [],
    ),
    Conversation(
      id: '3',
      title: 'Emergency Symptoms',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      messages: [],
    ),
    Conversation(
      id: '4',
      title: 'Medication Questions',
      timestamp: DateTime.now().subtract(const Duration(days: 14)),
      messages: [],
    ),
  ];
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
  ChatHistoryNotifier() : super(_mockChatHistory);

  void addSession(ChatSession session) {
    state = [session, ...state];
  }

  void removeSession(String sessionId) {
    state = state.where((session) => session.id != sessionId).toList();
  }

  static final List<ChatSession> _mockChatHistory = [
    ChatSession(
      id: '1',
      title: 'General Health Consultation',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
      messages: [],
    ),
    ChatSession(
      id: '2',
      title: 'Diabetes Management',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      lastMessageAt: DateTime.now().subtract(const Duration(days: 3)),
      messages: [],
    ),
    ChatSession(
      id: '3',
      title: 'Emergency Symptoms',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      lastMessageAt: DateTime.now().subtract(const Duration(days: 7)),
      messages: [],
    ),
    ChatSession(
      id: '4',
      title: 'Medication Questions',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      lastMessageAt: DateTime.now().subtract(const Duration(days: 14)),
      messages: [],
    ),
  ];
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  const ChatState.initial() : this();

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}