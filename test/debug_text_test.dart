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

// Mock classes
class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  group('Debug Text Content', () {
    late MockChatRepository mockChatRepository;

    setUp(() {
      mockChatRepository = MockChatRepository();
      registerFallbackValue(AiModel.availableModels.first);
    });

    testWidgets('Debug: Find all text widgets to understand content', (tester) async {
      // Setup mock
      when(() => mockChatRepository.getMockResponse(any(), any()))
          .thenAnswer((_) async => 'AI response here');

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

      // Find all text widgets and print their content
      final textWidgets = find.byType(Text);
      debugPrint('=== ALL TEXT CONTENT ===');
      for (final textWidget in textWidgets.evaluate()) {
        final text = textWidget.widget as Text;
        if (text.data != null) {
          debugPrint('Text: "${text.data}"');
        } else if (text.textSpan != null) {
          debugPrint('TextSpan: "${text.textSpan!.toPlainText()}"');
        }
      }
      debugPrint('=== END TEXT CONTENT ===');

      // Find all RichText widgets and print their content
      final richTextWidgets = find.byType(RichText);
      debugPrint('=== ALL RICHTEXT CONTENT ===');
      for (final richTextWidget in richTextWidgets.evaluate()) {
        final richText = richTextWidget.widget as RichText;
        debugPrint('RichText: "${richText.text.toPlainText()}"');
      }
      debugPrint('=== END RICHTEXT CONTENT ===');

      // This test should pass - we're just debugging
      expect(textWidgets, findsAtLeastNWidgets(1));
    });
  });
}