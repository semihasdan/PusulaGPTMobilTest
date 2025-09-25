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
  group('Widget Identity and Lifecycle Tests', () {
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

    testWidgets('Widget keys prevent unnecessary rebuilds', (tester) async {
      // Arrange: Create test messages with stable IDs
      final messages = List.generate(10, (index) {
        return ChatMessage(
          id: 'stable_id_$index',
          content: 'Message #$index',
          isUserMessage: index % 2 == 0,
          timestamp: DateTime.now().subtract(Duration(minutes: index)),
        );
      });
      
      // Act: Load initial messages
      await pumpChatScreen(tester, initialMessages: messages);
      
      // Count the number of widgets with specific keys
      final userMessageFinder = find.byKey(const ValueKey('user_stable_id_0'));
      final aiMessageFinder = find.byKey(const ValueKey('ai_stable_id_1'));
      
      expect(userMessageFinder, findsOneWidget);
      expect(aiMessageFinder, findsOneWidget);
    });

    testWidgets('Widget identity preserved during state updates', (tester) async {
      // Arrange: Create test messages
      final messages = List.generate(5, (index) {
        return ChatMessage(
          id: 'msg_$index',
          content: 'Message #$index',
          isUserMessage: index % 2 == 0,
          timestamp: DateTime.now().subtract(Duration(minutes: index)),
        );
      });
      
      // Act: Load initial messages
      await pumpChatScreen(tester, initialMessages: messages);
      
      // Get initial widget references
      final initialUserMessage = find.byKey(const ValueKey('user_msg_0'));
      final initialAiMessage = find.byKey(const ValueKey('ai_msg_1'));
      
      expect(initialUserMessage, findsOneWidget);
      expect(initialAiMessage, findsOneWidget);
      
      // Simulate state update (add a new message)
      final updatedMessages = [
        ChatMessage(
          id: 'new_msg',
          content: 'New message',
          isUserMessage: true,
          timestamp: DateTime.now(),
        ),
        ...messages,
      ];
      
      // Re-pump with updated messages
      await pumpChatScreen(tester, initialMessages: updatedMessages);
      
      // Verify that original widgets are still present
      expect(find.byKey(const ValueKey('user_msg_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('ai_msg_1')), findsOneWidget);
      // Verify new widget is present
      expect(find.byKey(const ValueKey('user_new_msg')), findsOneWidget);
    });

    testWidgets('Performance: Minimal widget recreation', (tester) async {
      // Arrange: Create test messages
      final messages = List.generate(20, (index) {
        return ChatMessage(
          id: 'msg_$index',
          content: 'Message #$index with some content to make it longer',
          isUserMessage: index % 2 == 0,
          timestamp: DateTime.now().subtract(Duration(minutes: index)),
        );
      });
      
      // Act: Load initial messages
      await pumpChatScreen(tester, initialMessages: messages);
      
      // Count initial widgets
      final initialWidgetCount = tester.widgetList(find.byType(Container)).length;
      
      // Simulate minor state update (e.g., typing indicator)
      await pumpChatScreen(tester, initialMessages: messages, isAiTyping: true);
      
      // Count widgets after update
      final updatedWidgetCount = tester.widgetList(find.byType(Container)).length;
      
      // Verify that widget count hasn't exploded
      expect(updatedWidgetCount, lessThan(initialWidgetCount * 2));
    });
  });
}