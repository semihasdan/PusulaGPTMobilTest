enum FeedbackState { none, liked, disliked }

class ChatMessage {
  final String id;
  final String content;
  final bool isUserMessage;
  final DateTime timestamp;
  final bool isLoading;
  final FeedbackState feedbackState;
  final String? thinkingProcess;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUserMessage,
    required this.timestamp,
    this.isLoading = false,
    this.feedbackState = FeedbackState.none,
    this.thinkingProcess,
  });

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUserMessage: true,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.ai(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUserMessage: false,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.loading() {
    return ChatMessage(
      id: 'loading',
      content: '',
      isUserMessage: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUserMessage,
    DateTime? timestamp,
    bool? isLoading,
    FeedbackState? feedbackState,
    String? thinkingProcess,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUserMessage: isUserMessage ?? this.isUserMessage,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
      feedbackState: feedbackState ?? this.feedbackState,
      thinkingProcess: thinkingProcess ?? this.thinkingProcess,
    );
  }
}