import 'chat_message.dart';
import 'ai_model.dart';

class Conversation {
  final String id;
  final String title;
  final DateTime timestamp;
  final DateTime lastUpdated; // ✅ Added for recency sorting
  final List<ChatMessage> messages;
  final AiModel modelUsed; // ✅ Added to track which model was used

  Conversation({
    required this.id,
    required this.title,
    required this.timestamp,
    DateTime? lastUpdated,
    required this.messages,
    required this.modelUsed,
  }) : lastUpdated = lastUpdated ?? timestamp;

  factory Conversation.create(String title, AiModel model) {
    final now = DateTime.now();
    return Conversation(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      timestamp: now,
      lastUpdated: now,
      messages: [],
      modelUsed: model,
    );
  }

  Conversation copyWith({
    String? id,
    String? title,
    DateTime? timestamp,
    DateTime? lastUpdated,
    List<ChatMessage>? messages,
    AiModel? modelUsed,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      messages: messages ?? this.messages,
      modelUsed: modelUsed ?? this.modelUsed,
    );
  }

  Conversation addMessage(ChatMessage message) {
    final now = DateTime.now();
    return copyWith(
      messages: [...messages, message],
      lastUpdated: now, // ✅ Update lastUpdated when adding messages
    );
  }
}