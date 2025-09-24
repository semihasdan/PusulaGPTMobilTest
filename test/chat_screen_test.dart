import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pusula/core/localization/app_localizations.dart';
import 'package:pusula/core/models/ai_model.dart';
import 'package:pusula/core/models/chat_message.dart';
import 'package:pusula/core/models/conversation.dart';
import 'package:pusula/core/models/chat_session.dart';
import 'package:pusula/core/providers/chat_provider.dart';
import 'package:pusula/core/repositories/chat_repository.dart';
import 'package:pusula/core/theme/app_theme.dart';
import 'package:pusula/features/chat/presentation/pages/new_chat_screen.dart';
import 'package:pusula/features/chat/presentation/widgets/typing_indicator.dart';

// Mock classes
class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  group('ChatScreen Widget Tests', () {
    late MockChatRepository mockChatRepository;

    setUp(() {
      mockChatRepository = MockChatRepository();
      
      // Register fallback values for mocktail
      registerFallbackValue(AiModel.availableModels.first);
    });

    // Helper function to create a properly configured test widget
    Future<void> pumpChatScreen(
      WidgetTester tester, {
      List<ChatMessage>? initialMessages,
      bool isAiTyping = false,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            chatRepositoryProvider.overrideWithValue(mockChatRepository),
            // Override the chat provider with initial state if needed
            if (initialMessages != null || isAiTyping)
              chatProvider.overrideWith((ref) {
                final notifier = ChatNotifier(ref);
                // Set initial state
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
      
      // Wait for localization to load
      await tester.pumpAndSettle();
    }

    testWidgets('Test Case 1: Sending a message and verifying immediate UI response', (tester) async {
      // Arrange
      when(() => mockChatRepository.getMockResponse(any(), any()))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return 'AI response here';
      });

      await pumpChatScreen(tester);

      // Find the text input field and send button
      final textField = find.byType(TextField);
      final sendButton = find.byIcon(Icons.send);

      expect(textField, findsOneWidget);
      expect(sendButton, findsOneWidget);

      // Act
      await tester.enterText(textField, 'Hello');
      await tester.pump();
      
      // Verify text is entered in the TextField
      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.controller?.text, 'Hello');
      
      await tester.tap(sendButton);
      await tester.pump(); // Pump once to trigger the state change
      await tester.pump(); // Pump again to let the UI update

      // Assert
      // Verify that the TextField is now empty after sending
      final updatedTextFieldWidget = tester.widget<TextField>(textField);
      expect(updatedTextFieldWidget.controller?.text, isEmpty);

      // Verify that the TypingIndicator widget is now visible
      expect(find.byType(TypingIndicator), findsOneWidget);

      // Wait for all async operations to complete
      await tester.pumpAndSettle();
    });

    testWidgets('Test Case 2: Receiving an AI response and verifying final state', (tester) async {
      // Arrange
      when(() => mockChatRepository.getMockResponse(any(), any()))
          .thenAnswer((_) async {
        // Simulate a delay
        await Future.delayed(const Duration(milliseconds: 100));
        return 'AI response here';
      });

      await pumpChatScreen(tester);

      // Send a message first
      final textField = find.byType(TextField);
      final sendButton = find.byIcon(Icons.send);

      await tester.enterText(textField, 'Hello');
      await tester.tap(sendButton);
      await tester.pump();
      await tester.pump();

      // Verify typing indicator is visible
      expect(find.byType(TypingIndicator), findsOneWidget);

      // Act
      // Wait for the AI response
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert
      // Verify that the TypingIndicator widget is no longer visible
      expect(find.byType(TypingIndicator), findsNothing);

      // Verify that a new message bubble with "AI response here" has been added
      expect(find.text('AI response here'), findsOneWidget);

      // Verify both user and AI messages are present
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('AI response here'), findsOneWidget);
    });

    testWidgets('Test Case 3: Stress-testing by sending messages rapidly', (tester) async {
      // Arrange
      when(() => mockChatRepository.getMockResponse(any(), any()))
          .thenAnswer((invocation) async {
        final message = invocation.positionalArguments[0] as String;
        await Future.delayed(const Duration(milliseconds: 50)); // Small delay
        return 'Response to: $message';
      });

      await pumpChatScreen(tester);

      final textField = find.byType(TextField);
      final sendButton = find.byIcon(Icons.send);

      // Act
      // Send multiple messages rapidly
      for (int i = 1; i <= 3; i++) {
        await tester.enterText(textField, 'Message $i');
        await tester.tap(sendButton);
        await tester.pump();
        await tester.pump();
        
        // Small delay to simulate rapid but not instantaneous sending
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Wait for all responses
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Assert
      // Verify that the TextField is empty
      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.controller?.text, isEmpty);

      // Verify that the correct number of user messages have been added
      expect(find.text('Message 1'), findsOneWidget);
      expect(find.text('Message 2'), findsOneWidget);
      expect(find.text('Message 3'), findsOneWidget);

      // Verify AI responses are present
      expect(find.text('Response to: Message 1'), findsOneWidget);
      expect(find.text('Response to: Message 2'), findsOneWidget);
      expect(find.text('Response to: Message 3'), findsOneWidget);

      // Verify no typing indicator is visible after all messages are processed
      expect(find.byType(TypingIndicator), findsNothing);
    });

    testWidgets('Test Case 4: Testing Drawer functionality', (tester) async {
      // Arrange
      await pumpChatScreen(tester);

      // Act
      // Find and tap the menu icon to open drawer
      final menuButton = find.byIcon(Icons.menu);
      expect(menuButton, findsOneWidget);
      
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // Assert
      // Verify that the drawer is opened and contains expected widgets
      expect(find.byType(Drawer), findsOneWidget);
      
      // Look for drawer content
      expect(find.text('PusulaGPT'), findsOneWidget); // Model name in drawer
      expect(find.text('New Chat'), findsOneWidget); // New chat button
      
      // Verify user tags are present in drawer
      expect(find.text('Administrator'), findsOneWidget);
      expect(find.text('⭐ Premium'), findsOneWidget);
      expect(find.text('Unlimited'), findsOneWidget);
    });

    testWidgets('Test Case 5: Testing Model Selector functionality', (tester) async {
      // Arrange
      await pumpChatScreen(tester);

      // Act
      // Find the model selector button (should contain the current model name)
      final modelSelector = find.text('PusulaGPT (General)');
      expect(modelSelector, findsOneWidget);
      
      await tester.tap(modelSelector);
      await tester.pumpAndSettle();

      // Assert
      // Verify that the modal bottom sheet is opened
      // Look for model options in the sheet
      expect(find.text('Select AI Model'), findsOneWidget);
      expect(find.text('PusulaGPT (General)'), findsAtLeastNWidgets(1));
      expect(find.text('ComedGPT (Clinical)'), findsOneWidget);
      expect(find.text('MedDiabet (Specialized)'), findsOneWidget);
    });

    testWidgets('Test Case 6: Testing empty state display', (tester) async {
      // Arrange
      await pumpChatScreen(tester);

      // Assert
      // Verify welcome message is displayed when no messages exist
      expect(find.text('Hello, user@example.com'), findsOneWidget);
      expect(find.text('How can I help you?'), findsOneWidget);
      
      // Verify chat icon is present
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('Test Case 7: Testing input field behavior', (tester) async {
      // Arrange
      when(() => mockChatRepository.getMockResponse(any(), any()))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return 'AI response';
      });

      await pumpChatScreen(tester);

      final textField = find.byType(TextField);
      final sendButton = find.byIcon(Icons.send);

      // Act & Assert
      // Test that send button is initially enabled
      expect(sendButton, findsOneWidget);
      
      // Test entering text
      await tester.enterText(textField, 'Test message');
      await tester.pump();
      
      // Verify text is in the TextField
      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.controller?.text, 'Test message');
      
      // Test that tapping send clears the field
      await tester.tap(sendButton);
      await tester.pump();
      await tester.pump();
      
      final updatedTextFieldWidget = tester.widget<TextField>(textField);
      expect(updatedTextFieldWidget.controller?.text, isEmpty);

      // Wait for all async operations to complete
      await tester.pumpAndSettle();
    });

    testWidgets('Test Case 8: Testing scroll behavior with multiple messages', (tester) async {
      // Arrange
      when(() => mockChatRepository.getMockResponse(any(), any()))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return 'AI response';
      });

      await pumpChatScreen(tester);

      final textField = find.byType(TextField);
      final sendButton = find.byIcon(Icons.send);

      // Act
      // Send multiple messages to test scrolling
      for (int i = 1; i <= 5; i++) {
        await tester.enterText(textField, 'Message $i');
        await tester.tap(sendButton);
        await tester.pump();
        await tester.pump();
        
        // Wait for each message to be processed
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Final wait to ensure all operations complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert
      // Verify all messages are present
      for (int i = 1; i <= 5; i++) {
        expect(find.text('Message $i'), findsOneWidget);
      }
      
      // The ListView should have scrolled to show the latest messages
      // We can verify this by checking that the latest message is visible
      expect(find.text('Message 5'), findsOneWidget);
    });
  });
}