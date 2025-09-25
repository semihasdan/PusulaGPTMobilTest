import 'package:flutter_test/flutter_test.dart';
import 'package:pusula/core/models/chat_message.dart';
import 'package:pusula/core/repositories/chat_repository.dart';

void main() {
  group('Conversation History Test', () {
    late ChatRepository chatRepository;

    setUp(() {
      chatRepository = ChatRepository();
    });

    test('Messages are stored and retrieved correctly', () async {
      // Arrange
      final conversationId = 'test_conversation_1';
      final userMessage = ChatMessage.user('Hello, how are you?');
      final aiMessage = ChatMessage.ai('I am doing well, thank you!');

      // Act - Store messages
      chatRepository.addMessage(conversationId, userMessage);
      chatRepository.addMessage(conversationId, aiMessage);

      // Retrieve messages
      final messages = await chatRepository.getMessages(conversationId);

      // Assert
      expect(messages, isNotEmpty);
      expect(messages.length, 2);
      expect(messages[0].content, 'I am doing well, thank you!');
      expect(messages[1].content, 'Hello, how are you?');
      expect(messages[0].isUserMessage, false);
      expect(messages[1].isUserMessage, true);
    });

    test('Multiple conversations are isolated', () async {
      // Arrange
      final conversationId1 = 'test_conversation_1';
      final conversationId2 = 'test_conversation_2';
      
      final message1 = ChatMessage.user('Message in conversation 1');
      final message2 = ChatMessage.user('Message in conversation 2');

      // Act - Store messages in different conversations
      chatRepository.addMessage(conversationId1, message1);
      chatRepository.addMessage(conversationId2, message2);

      // Retrieve messages for each conversation
      final messages1 = await chatRepository.getMessages(conversationId1);
      final messages2 = await chatRepository.getMessages(conversationId2);

      // Assert
      expect(messages1.length, 1);
      expect(messages2.length, 1);
      expect(messages1[0].content, 'Message in conversation 1');
      expect(messages2[0].content, 'Message in conversation 2');
    });

    test('Basic storage and retrieval works', () async {
      // Arrange
      final conversationId = 'test_conversation_basic';
      
      // Add multiple messages
      for (int i = 0; i < 5; i++) {
        final message = ChatMessage.user('Message $i');
        chatRepository.addMessage(conversationId, message);
      }

      // Act - Retrieve messages
      final messages = await chatRepository.getMessages(conversationId);

      // Assert - Check that we get the messages in reverse order (newest first)
      expect(messages.length, 5);
      expect(messages[0].content, 'Message 4'); // Newest first
      expect(messages[4].content, 'Message 0'); // Oldest last
    });

    test('Messages are displayed in correct chronological order when loading conversation', () async {
      // Arrange
      final conversationId = 'test_conversation_order';
      
      // Add messages in chronological order (oldest to newest)
      final messages = [
        ChatMessage.user('First message'),
        ChatMessage.ai('First response'),
        ChatMessage.user('Second message'),
        ChatMessage.ai('Second response'),
        ChatMessage.user('Third message'),
        ChatMessage.ai('Third response'),
      ];
      
      // Store all messages
      for (final message in messages) {
        chatRepository.addMessage(conversationId, message);
      }

      // Act - Retrieve messages (simulating what happens when loading a conversation)
      final retrievedMessages = await chatRepository.getMessages(conversationId);

      // Assert - Messages should be returned in reverse order (newest first)
      // This is what the UI expects for proper display in reversed ListView
      expect(retrievedMessages.length, 6);
      expect(retrievedMessages[0].content, 'Third response'); // Newest
      expect(retrievedMessages[1].content, 'Third message');
      expect(retrievedMessages[2].content, 'Second response');
      expect(retrievedMessages[3].content, 'Second message');
      expect(retrievedMessages[4].content, 'First response');
      expect(retrievedMessages[5].content, 'First message');  // Oldest
    });

    test('Pagination maintains correct message order when loading conversation', () async {
      // Arrange
      final conversationId = 'test_conversation_full_flow';
      
      // Add messages in chronological order
      final messages = List.generate(25, (i) => ChatMessage.user('Message $i'));
      for (final message in messages) {
        chatRepository.addMessage(conversationId, message);
      }

      // Act - Simulate loading conversation (first page)
      final firstPage = await chatRepository.getMessages(conversationId, page: 1, limit: 20);
      
      // Simulate loading more messages (second page)
      final secondPage = await chatRepository.getMessages(conversationId, page: 2, limit: 20);

      // Assert - First page should have newest messages (24 down to 5)
      expect(firstPage.length, 20);
      expect(firstPage[0].content, 'Message 24'); // Newest first
      expect(firstPage[19].content, 'Message 5'); // Oldest in first page
      
      // Second page should have older messages (4 down to 0)
      expect(secondPage.length, 5);
      expect(secondPage[0].content, 'Message 4'); // Newest in second page
      expect(secondPage[4].content, 'Message 0'); // Oldest overall
    });
  });
}