import 'chat_message.dart';

class Conversation {
  final String id;
  final String title;
  final DateTime timestamp;
  final List<ChatMessage> messages;

  Conversation({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.messages,
  });

  factory Conversation.create(String title) {
    final now = DateTime.now();
    return Conversation(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      timestamp: now,
      messages: [],
    );
  }

  Conversation copyWith({
    String? id,
    String? title,
    DateTime? timestamp,
    List<ChatMessage>? messages,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
      messages: messages ?? this.messages,
    );
  }

  Conversation addMessage(ChatMessage message) {
    return copyWith(
      messages: [...messages, message],
      timestamp: DateTime.now(),
    );
  }
}