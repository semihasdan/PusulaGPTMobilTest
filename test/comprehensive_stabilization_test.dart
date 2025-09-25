import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pusula/core/localization/app_localizations.dart';
import 'package:pusula/core/models/chat_message.dart';
import 'package:pusula/core/providers/chat_provider.dart';
import 'package:pusula/core/theme/app_theme.dart';
import 'package:pusula/features/chat/presentation/pages/new_chat_screen.dart';
import 'mock_chat_repository.dart';

void main() {
  group('Comprehensive Stabilization Test', () {
    late MockChatRepository mockChatRepository;

    setUp(() {
      mockChatRepository = MockChatRepository();
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

    testWidgets('All stabilization fixes work together', (tester) async {
      // Arrange: Create test messages
      final messages = List.generate(50, (index) {
        return ChatMessage(
          id: 'msg_$index',
          content: 'Message #$index: This is a test message with some content to make it longer',
          isUserMessage: index % 2 == 0,
          timestamp: DateTime.now().subtract(Duration(minutes: index)),
        );
      });
      
      mockChatRepository.setConversationData('test_conv', messages);
      
      // Act: Load initial messages
      await pumpChatScreen(tester, initialMessages: messages.sublist(30));
      
      // Assert: Verify user messages display correct content (no corruption)
      for (int i = 30; i < 50; i += 2) {
        expect(find.text('Message #$i: This is a test message with some content to make it longer'), findsOneWidget);
      }
      
      // Test scroll position stability
      final scrollable = find.byType(Scrollable);
      expect(scrollable, findsOneWidget);
      
      // Scroll to trigger pagination
      await tester.drag(scrollable, const Offset(0, 300));
      await tester.pump();
      
      // Verify that we still see the same messages (scroll position stable)
      expect(find.text('Message #30: This is a test message with some content to make it longer'), findsOneWidget);
      
      // Test that no duplicate pagination requests occur
      await tester.drag(scrollable, const Offset(0, 300));
      await tester.pump();
      
      // Verify only one loading indicator (no duplicates)
      expect(find.text('Loading older messages...'), findsAtMost(1));
      
      // Test widget identity preservation
      final userMessageFinder = find.byKey(const ValueKey('user_msg_30'));
      final aiMessageFinder = find.byKey(const ValueKey('ai_msg_31'));
      
      expect(userMessageFinder, findsOneWidget);
      expect(aiMessageFinder, findsOneWidget);
    });

    testWidgets('Error handling works correctly', (tester) async {
      // Arrange: Enable error simulation
      mockChatRepository.enableErrorSimulation(true);
      
      // Act: Try to load messages
      await pumpChatScreen(tester);
      
      // Find the text input field and send button
      final textField = find.byType(TextField);
      final sendButton = find.byIcon(Icons.send);
      
      await tester.enterText(textField, 'Test message');
      await tester.tap(sendButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      
      // Assert: Verify error message is displayed
      expect(find.text('An error occurred: Exception: Simulated network error'), findsOneWidget);
    });

    testWidgets('Accessibility features work correctly', (tester) async {
      // Arrange: Create test messages
      final messages = [
        ChatMessage(
          id: 'user_msg_1',
          content: 'User message content',
          isUserMessage: true,
          timestamp: DateTime.now(),
        ),
        ChatMessage(
          id: 'ai_msg_1',
          content: 'AI response content',
          isUserMessage: false,
          timestamp: DateTime.now(),
        ),
      ];
      
      // Act: Load messages
      await pumpChatScreen(tester, initialMessages: messages);
      
      // Assert: Verify semantic labels are present
      expect(find.bySemanticsLabel('User message: User message content'), findsOneWidget);
      expect(find.bySemanticsLabel('AI response: AI response content'), findsOneWidget);
      expect(find.bySemanticsLabel('AI assistant is typing'), findsNothing);
      
      // Test with typing indicator
      await pumpChatScreen(tester, initialMessages: messages, isAiTyping: true);
      expect(find.bySemanticsLabel('AI assistant is typing'), findsOneWidget);
    });
  });
}