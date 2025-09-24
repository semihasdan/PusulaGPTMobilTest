import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pusula/core/localization/app_localizations.dart';
import 'package:pusula/core/models/ai_model.dart';
import 'package:pusula/core/providers/chat_provider.dart';
import 'package:pusula/core/repositories/chat_repository.dart';
import 'package:pusula/core/theme/app_theme.dart';
import 'package:pusula/features/chat/presentation/pages/new_chat_screen.dart';
import 'package:pusula/features/chat/presentation/widgets/typing_indicator.dart';

// Mock classes
class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  group('Debug State Changes', () {
    late MockChatRepository mockChatRepository;

    setUp(() {
      mockChatRepository = MockChatRepository();
      registerFallbackValue(AiModel.availableModels.first);
    });

    testWidgets('Debug: Check state changes after sending message', (tester) async {
      // Setup mock
      when(() => mockChatRepository.getMockResponse(any(), any()))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return 'AI response here';
      });

      // Create container with all necessary overrides
      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(mockChatRepository),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
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

      // Check initial state
      debugPrint('=== INITIAL STATE ===');
      final initialState = container.read(chatProvider);
      debugPrint('Messages: ${initialState.messages.length}');
      debugPrint('IsAiTyping: ${initialState.isAiTyping}');
      debugPrint('IsLoading: ${initialState.isLoading}');
      
      final typingIndicatorsBefore = find.byType(TypingIndicator);
      debugPrint('TypingIndicators found before: ${typingIndicatorsBefore.evaluate().length}');

      // Send a message
      final textField = find.byType(TextField);
      final sendButton = find.byIcon(Icons.send);

      await tester.enterText(textField, 'Hello');
      await tester.tap(sendButton);
      await tester.pump(); // First pump to trigger state change
      
      // Check state after sending
      debugPrint('=== STATE AFTER SENDING ===');
      final stateAfterSending = container.read(chatProvider);
      debugPrint('Messages: ${stateAfterSending.messages.length}');
      debugPrint('IsAiTyping: ${stateAfterSending.isAiTyping}');
      debugPrint('IsLoading: ${stateAfterSending.isLoading}');
      
      final typingIndicatorsAfter = find.byType(TypingIndicator);
      debugPrint('TypingIndicators found after: ${typingIndicatorsAfter.evaluate().length}');

      await tester.pump(); // Second pump to update UI
      
      // Check state after UI update
      debugPrint('=== STATE AFTER UI UPDATE ===');
      final stateAfterUI = container.read(chatProvider);
      debugPrint('Messages: ${stateAfterUI.messages.length}');
      debugPrint('IsAiTyping: ${stateAfterUI.isAiTyping}');
      debugPrint('IsLoading: ${stateAfterUI.isLoading}');
      
      final typingIndicatorsAfterUI = find.byType(TypingIndicator);
      debugPrint('TypingIndicators found after UI: ${typingIndicatorsAfterUI.evaluate().length}');

      // Print all widgets to see what's in the tree
      debugPrint('=== ALL WIDGETS AFTER SENDING ===');
      final allWidgets = tester.allWidgets.map((w) => w.runtimeType.toString()).toList();
      final uniqueWidgets = allWidgets.toSet().toList()..sort();
      for (final widget in uniqueWidgets) {
        if (widget.contains('Typing') || widget.contains('Indicator') || widget.contains('Chat') || widget.contains('Message')) {
          debugPrint('Widget: $widget');
        }
      }
      debugPrint('=== END WIDGETS ===');

      // This test should pass - we're just debugging
      expect(textField, findsOneWidget);
    });
  });
}