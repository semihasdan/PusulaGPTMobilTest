import '../models/ai_model.dart';
import '../models/chat_message.dart';

class ChatRepository {
  // ✅ Store conversations in memory to preserve history
  final Map<String, List<ChatMessage>> _conversationStorage = {};
  
  // ✅ New paginated message fetching method
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 20,
  }) async {
    // Simulate network delay for pagination
    await Future.delayed(const Duration(milliseconds: 800));
    
    // ✅ Return stored messages for the conversation in chronological order
    final conversationMessages = _conversationStorage[conversationId] ?? [];
    
    // Calculate pagination - return messages in chronological order
    // The UI will handle the display order
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    // Return empty list if we've reached the end
    if (startIndex >= conversationMessages.length) {
      return [];
    }
    
    // Return the requested page of messages in chronological order
    return conversationMessages.sublist(
      startIndex,
      endIndex > conversationMessages.length ? conversationMessages.length : endIndex,
    );
  }

  // ✅ Method to store messages for a conversation
  void storeMessages(String conversationId, List<ChatMessage> messages) {
    _conversationStorage[conversationId] = messages;
  }

  // ✅ Method to add a message to a conversation
  void addMessage(String conversationId, ChatMessage message) {
    final messages = _conversationStorage[conversationId] ?? [];
    messages.add(message);
    _conversationStorage[conversationId] = messages;
  }

  Future<String> getMockResponse(String userInput, AiModel selectedModel) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Return a simple response without any sample text
    return "I understand your question about: $userInput";
  }

  Map<String, String> _getMockResponses(AiModel model) {
    // Return empty map to avoid any sample responses
    return {};
  }
}