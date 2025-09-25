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
  group('Pagination Tests', () {
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

    testWidgets('User prompt content integrity during pagination', (tester) async {
      // Arrange: Create test messages
      final messages = List.generate(50, (index) {
        return ChatMessage(
          id: 'msg_$index',
          content: 'User message #$index: This is a test message',
          isUserMessage: index % 2 == 0,
          timestamp: DateTime.now().subtract(Duration(minutes: index)),
        );
      });
      
      mockChatRepository.setConversationData('test_conv', messages);
      
      // Act: Load initial messages
      await pumpChatScreen(tester, initialMessages: messages.sublist(30));
      
      // Assert: Verify user messages display correct content
      for (int i = 30; i < 50; i += 2) {
        if (i < 50) {
          expect(find.text('User message #$i: This is a test message'), findsOneWidget);
        }
      }
    });

    testWidgets('Scroll position stability during pagination', (tester) async {
      // Arrange: Create many test messages
      final messages = List.generate(100, (index) {
        return ChatMessage(
          id: 'msg_$index',
          content: 'Message #$index: This is a test message with some content to make it longer',
          isUserMessage: index % 2 == 0,
          timestamp: DateTime.now().subtract(Duration(minutes: index)),
        );
      });
      
      mockChatRepository.setConversationData('test_conv', messages);
      
      // Act: Load initial messages
      await pumpChatScreen(tester, initialMessages: messages.sublist(80));
      
      // Find the scrollable widget
      final scrollable = find.byType(Scrollable);
      expect(scrollable, findsOneWidget);
      
      // Scroll to trigger pagination
      await tester.drag(scrollable, const Offset(0, 500));
      await tester.pumpAndSettle();
      
      // Verify that we still see the same messages
      expect(find.text('Message #80: This is a test message with some content to make it longer'), findsOneWidget);
    });

    testWidgets('End of history stops loading attempts', (tester) async {
      // Arrange: Create few messages
      final messages = List.generate(5, (index) {
        return ChatMessage(
          id: 'msg_$index',
          content: 'Message #$index',
          isUserMessage: index % 2 == 0,
          timestamp: DateTime.now().subtract(Duration(minutes: index)),
        );
      });
      
      mockChatRepository.setConversationData('test_conv', messages);
      
      // Act: Load initial messages
      await pumpChatScreen(tester, initialMessages: messages);
      
      // Try to scroll to trigger pagination
      final scrollable = find.byType(Scrollable);
      await tester.drag(scrollable, const Offset(0, 1000));
      await tester.pumpAndSettle();
      
      // Verify that no additional messages were loaded
      expect(find.text('Loading older messages...'), findsNothing);
    });

    testWidgets('Prevent duplicate pagination requests', (tester) async {
      // Arrange: Create many test messages
      final messages = List.generate(100, (index) {
        return ChatMessage(
          id: 'msg_$index',
          content: 'Message #$index',
          isUserMessage: index % 2 == 0,
          timestamp: DateTime.now().subtract(Duration(minutes: index)),
        );
      });
      
      mockChatRepository.setConversationData('test_conv', messages);
      mockChatRepository.setNetworkDelay(const Duration(seconds: 2)); // Slow network
      
      // Act: Load initial messages
      await pumpChatScreen(tester, initialMessages: messages.sublist(80));
      
      // Try to scroll multiple times quickly
      final scrollable = find.byType(Scrollable);
      await tester.drag(scrollable, const Offset(0, 500));
      await tester.pump();
      
      // Try to trigger another pagination request immediately
      await tester.drag(scrollable, const Offset(0, 500));
      await tester.pump();
      
      // Verify only one loading indicator
      expect(find.text('Loading older messages...'), findsOneWidget);
    });
  });
}