import 'chat_message.dart';

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
    required this.messages,
  });

  factory ChatSession.create(String title) {
    final now = DateTime.now();
    return ChatSession(
      id: now.millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: now,
      lastMessageAt: now,
      messages: [],
    );
  }

  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    List<ChatMessage>? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messages: messages ?? this.messages,
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }
}