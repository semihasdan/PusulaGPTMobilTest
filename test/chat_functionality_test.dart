import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pusula/core/models/ai_model.dart';
import 'package:pusula/core/models/chat_message.dart';
import 'package:pusula/core/providers/chat_provider.dart';
import 'package:pusula/core/repositories/chat_repository.dart';

// Mock classes
class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  group('Chat Functionality Tests', () {
    late MockChatRepository mockChatRepository;
    late ProviderContainer container;

    setUp(() {
      mockChatRepository = MockChatRepository();
      
      // Register fallback values for mocktail
      registerFallbackValue(AiModel.availableModels.first);
      
      container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(mockChatRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Should send message and receive AI response', () async {
      // Arrange
      when(() => mockChatRepository.getMockResponse(any(), any()))
          .thenAnswer((_) async => 'AI response here');

      final chatNotifier = container.read(chatProvider.notifier);
      
      // Act
      await chatNotifier.sendMessage('Hello');
      
      // Assert
      final chatState = container.read(chatProvider);
      expect(chatState.messages.length, equals(2)); // User message + AI response
      expect(chatState.messages.first.content, equals('Hello'));
      expect(chatState.messages.first.isUserMessage, isTrue);
      expect(chatState.messages.last.content, equals('AI response here'));
      expect(chatState.messages.last.isUserMessage, isFalse);
      expect(chatState.isLoading, isFalse);
      expect(chatState.isAiTyping, isFalse);
    });

    test('Should show typing indicator during AI response', () async {
      // Arrange
      when(() => mockChatRepository.getMockResponse(any(), any()))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return 'AI response';
      });

      final chatNotifier = container.read(chatProvider.notifier);
      
      // Act
      final future = chatNotifier.sendMessage('Hello');
      
      // Check intermediate state (should show typing)
      await Future.delayed(const Duration(milliseconds: 50));
      var chatState = container.read(chatProvider);
      expect(chatState.isAiTyping, isTrue);
      expect(chatState.isLoading, isTrue);
      
      // Wait for completion
      await future;
      
      // Assert final state
      chatState = container.read(chatProvider);
      expect(chatState.isAiTyping, isFalse);
      expect(chatState.isLoading, isFalse);
      expect(chatState.messages.length, equals(2));
    });

    test('Should handle multiple rapid messages', () async {
      // Arrange
      when(() => mockChatRepository.getMockResponse(any(), any()))
          .thenAnswer((invocation) async {
        final message = invocation.positionalArguments[0] as String;
        return 'Response to: $message';
      });

      final chatNotifier = container.read(chatProvider.notifier);
      
      // Act
      await chatNotifier.sendMessage('Message 1');
      await chatNotifier.sendMessage('Message 2');
      await chatNotifier.sendMessage('Message 3');
      
      // Assert
      final chatState = container.read(chatProvider);
      expect(chatState.messages.length, equals(6)); // 3 user + 3 AI messages
      
      // Verify message order and content
      expect(chatState.messages[0].content, equals('Message 1'));
      expect(chatState.messages[1].content, equals('Response to: Message 1'));
      expect(chatState.messages[2].content, equals('Message 2'));
      expect(chatState.messages[3].content, equals('Response to: Message 2'));
      expect(chatState.messages[4].content, equals('Message 3'));
      expect(chatState.messages[5].content, equals('Response to: Message 3'));
    });

    test('Should clear messages when starting new chat', () async {
      // Arrange
      when(() => mockChatRepository.getMockResponse(any(), any()))
          .thenAnswer((_) async => 'AI response');

      final chatNotifier = container.read(chatProvider.notifier);
      
      // Add some messages first
      await chatNotifier.sendMessage('Hello');
      expect(container.read(chatProvider).messages.length, equals(2));
      
      // Act
      chatNotifier.clearMessages();
      
      // Assert
      final chatState = container.read(chatProvider);
      expect(chatState.messages.length, equals(0));
      expect(chatState.isLoading, isFalse);
      expect(chatState.isAiTyping, isFalse);
    });

    test('Should handle model selection', () {
      // Arrange
      final modelNotifier = container.read(selectedModelProvider.notifier);
      final newModel = AiModel.availableModels[1]; // ComedGPT
      
      // Act
      modelNotifier.selectModel(newModel);
      
      // Assert
      final selectedModel = container.read(selectedModelProvider);
      expect(selectedModel.id, equals('comed'));
      expect(selectedModel.name, equals('ComedGPT'));
    });

    test('Should handle conversation management', () {
      // Arrange
      final conversationsNotifier = container.read(conversationsProvider.notifier);
      final activeConversationNotifier = container.read(activeConversationProvider.notifier);
      
      // Act
      activeConversationNotifier.setActiveConversation('test-id');
      
      // Assert
      final activeId = container.read(activeConversationProvider);
      expect(activeId, equals('test-id'));
      
      // Test clearing
      activeConversationNotifier.clearActiveConversation();
      final clearedId = container.read(activeConversationProvider);
      expect(clearedId, isNull);
    });

    test('Should handle error states gracefully', () async {
      // Arrange
      when(() => mockChatRepository.getMockResponse(any(), any()))
          .thenThrow(Exception('Network error'));

      final chatNotifier = container.read(chatProvider.notifier);
      
      // Act
      await chatNotifier.sendMessage('Hello');
      
      // Assert
      final chatState = container.read(chatProvider);
      expect(chatState.messages.length, equals(2)); // User message + error message
      expect(chatState.messages.first.content, equals('Hello'));
      expect(chatState.messages.last.content, contains('Sorry, I encountered an error'));
      expect(chatState.isLoading, isFalse);
      expect(chatState.isAiTyping, isFalse);
      expect(chatState.error, isNotNull);
    });
  });
}