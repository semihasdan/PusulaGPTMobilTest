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
  group('ChatScreen Widget Tests - Fixed', () {
    late MockChatRepository mockChatRepository;

    setUp(() {
      mockChatRepository = MockChatRepository();
      registerFallbackValue(AiModel.availableModels.first);
    });

    // Helper function to create a properly configured test widget with full isolation
    Future<void> pumpChatScreen(
      WidgetTester tester, {
      List<ChatMessage>? initialMessages,
      bool isAiTyping = false,
    }) async {
      // Ensure clean state before each test
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
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
      
      // Wait for localization to load and all initial animations to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));
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
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('Test Case 2: Testing empty state display', (tester) async {
      // Arrange
      await pumpChatScreen(tester);

      // Assert
      // Verify welcome message is displayed when no messages exist
      expect(find.text('Hello, user@example.com'), findsOneWidget);
      expect(find.text('How can I help you?'), findsOneWidget);
      
      // Verify chat icon is present
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('Test Case 3: Testing input field behavior', (tester) async {
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
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('Test Case 4: Receiving an AI response and verifying final state', (tester) async {
      // Arrange
      when(() => mockChatRepository.getMockResponse(any(), any()))
          .thenAnswer((_) async {
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
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assert
      // Verify that the TypingIndicator widget is no longer visible
      expect(find.byType(TypingIndicator), findsNothing);

      // Verify that a new message bubble with "AI response here" has been added
      expect(find.text('AI response here'), findsOneWidget);

      // Verify both user and AI messages are present
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('AI response here'), findsOneWidget);
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
  });
}