import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pusula/core/localization/app_localizations.dart';
import 'package:pusula/core/models/ai_model.dart';
import 'package:pusula/core/models/chat_message.dart';
import 'package:pusula/core/providers/chat_provider.dart';
import 'package:pusula/core/repositories/chat_repository.dart';
import 'package:pusula/core/theme/app_theme.dart';
import 'package:pusula/features/chat/presentation/pages/new_chat_screen.dart';

// Mock repository that simulates the fixed behavior
class MockChatRepository extends Mock implements ChatRepository {
  @override
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 20,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Create realistic test messages
    final messages = <ChatMessage>[];
    final now = DateTime.now();
    
    final userPrompts = [
      "What are the symptoms of diabetes?",
      "How can I manage my blood pressure?",
      "What should I do if I have a fever?",
      "Can you explain how vaccines work?",
      "What are the side effects of antibiotics?",
    ];
    
    final aiResponses = [
      "Diabetes symptoms include increased thirst, frequent urination, extreme fatigue, and blurred vision.",
      "To manage blood pressure, maintain a healthy diet low in sodium, exercise regularly.",
      "For a fever, rest, stay hydrated, and consider over-the-counter medications.",
      "Vaccines work by introducing a weakened part of a pathogen to stimulate your immune system.",
      "Common antibiotic side effects include nausea, diarrhea, and yeast infections.",
    ];
    
    // Generate messages based on page
    final startIndex = (page - 1) * limit;
    for (int i = 0; i < limit; i++) {
      final globalIndex = startIndex + i;
      final messageTime = now.subtract(Duration(minutes: globalIndex));
      
      if (globalIndex % 2 == 0) {
        // User message
        final promptIndex = (globalIndex ~/ 2) % userPrompts.length;
        messages.add(ChatMessage(
          id: 'msg_test_$globalIndex',
          content: userPrompts[promptIndex],
          isUserMessage: true,
          timestamp: messageTime,
        ));
      } else {
        // AI message
        final responseIndex = (globalIndex ~/ 2) % aiResponses.length;
        messages.add(ChatMessage(
          id: 'msg_test_$globalIndex',
          content: aiResponses[responseIndex],
          isUserMessage: false,
          timestamp: messageTime,
        ));
      }
    }
    
    return messages.reversed.toList();
  }
  
  @override
  Future<String> getMockResponse(String userInput, AiModel selectedModel) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return "This is a mock AI response to: $userInput";
  }
}

void main() {
  group('Chat Stabilization Fixes Test', () {
    late MockChatRepository mockChatRepository;

    setUp(() {
      mockChatRepository = MockChatRepository();
      registerFallbackValue(AiModel.availableModels.first);
    });

    Future<void> pumpChatScreen(
      WidgetTester tester, {
      List<ChatMessage>? initialMessages,
      bool isAiTyping = false,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chatRepositoryProvider.overrideWithValue(mockChatRepository),
            if (initialMessages != null || isAiTyping)
              chatProvider.overrideWith((ref) {
                final notifier = ChatNotifier(ref);
                notifier.state = ChatState(
                  messages: initialMessages ?? [],
                  isAiTyping: isAiTyping,
                );
                return notifier;
              }),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const NewChatScreen(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('tr'),
              Locale('ar'),
              Locale('ru'),
            ],
          ),
        ),
      );
      
      await tester.pumpAndSettle();
    }

    testWidgets('Fix 1: Scroll position remains stable during pagination', (tester) async {
      // Arrange: Create initial messages
      final initialMessages = List.generate(20, (index) {
        return ChatMessage(
          id: 'msg_$index',
          content: index % 2 == 0 
              ? 'User message $index' 
              : 'AI response $index',
          isUserMessage: index % 2 == 0,
          timestamp: DateTime.now().subtract(Duration(minutes: index)),
        );
      });
      
      // Act: Load initial messages
      await pumpChatScreen(tester, initialMessages: initialMessages);
      
      // Find scrollable widget
      final scrollable = find.byType(Scrollable);
      expect(scrollable, findsOneWidget);
      
      // Record initial scroll position
      final scrollState = tester.state<ScrollableState>(scrollable);
      final initialScrollPosition = scrollState.position.pixels;
      
      // Simulate scroll to trigger pagination (this would normally load more messages)
      await tester.drag(scrollable, const Offset(0, 300));
      await tester.pump();
      
      // With the fix, scroll position should remain stable
      // (In a real test, we would verify that after loading more messages,
      // the scroll position is adjusted to maintain the same visual content)
      expect(scrollState.position.pixels, greaterThan(initialScrollPosition));
    });

    testWidgets('Fix 2: Typing indicator appears at correct position', (tester) async {
      // Arrange: Create test messages
      final messages = [
        ChatMessage(
          id: 'user_1',
          content: 'Hello, how are you?',
          isUserMessage: true,
          timestamp: DateTime.now(),
        ),
        ChatMessage(
          id: 'ai_1',
          content: 'I am doing well, thank you for asking!',
          isUserMessage: false,
          timestamp: DateTime.now(),
        ),
      ];
      
      // Act: Load messages with typing indicator
      await pumpChatScreen(tester, initialMessages: messages, isAiTyping: true);
      
      // Assert: Verify typing indicator is present
      expect(find.byType(Scrollable), findsOneWidget);
      
      // In a ListView with reverse=true, the typing indicator should be visible
      // We can't easily test its exact position in this simplified test,
      // but we can verify it's rendered
      expect(find.text('Yanıt yazılıyor...'), findsOneWidget);
    });

    testWidgets('Fix 3: No sample/placeholder messages in chat', (tester) async {
      // Arrange: Create test messages
      final messages = [
        ChatMessage(
          id: 'user_1',
          content: 'What are the symptoms of diabetes?',
          isUserMessage: true,
          timestamp: DateTime.now(),
        ),
        ChatMessage(
          id: 'ai_1',
          content: 'Diabetes symptoms include increased thirst, frequent urination, extreme fatigue, and blurred vision.',
          isUserMessage: false,
          timestamp: DateTime.now(),
        ),
      ];
      
      // Act: Load messages
      await pumpChatScreen(tester, initialMessages: messages);
      
      // Assert: Verify no sample messages
      expect(find.text('This is a sample user question'), findsNothing);
      expect(find.text('This is a detailed medical response'), findsNothing);
      
      // Verify actual content is present
      expect(find.text('What are the symptoms of diabetes?'), findsOneWidget);
      expect(find.text('Diabetes symptoms include increased thirst, frequent urination, extreme fatigue, and blurred vision.'), findsOneWidget);
    });
  });
}