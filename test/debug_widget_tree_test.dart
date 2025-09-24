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
  group('Debug Widget Tree', () {
    late MockChatRepository mockChatRepository;

    setUp(() {
      mockChatRepository = MockChatRepository();
      registerFallbackValue(AiModel.availableModels.first);
    });

    testWidgets('Debug: Print widget tree to understand structure', (tester) async {
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

      // Print the widget tree to debug
      debugPrint('=== WIDGET TREE DEBUG ===');
      debugPrint(tester.allWidgets.map((w) => w.runtimeType.toString()).join('\n'));
      debugPrint('=== END WIDGET TREE ===');

      // Try to find basic widgets
      final scaffolds = find.byType(Scaffold);
      final columns = find.byType(Column);
      final containers = find.byType(Container);
      final textFields = find.byType(TextField);
      final icons = find.byIcon(Icons.send);
      final menuIcons = find.byIcon(Icons.menu);

      debugPrint('Scaffolds found: ${scaffolds.evaluate().length}');
      debugPrint('Columns found: ${columns.evaluate().length}');
      debugPrint('Containers found: ${containers.evaluate().length}');
      debugPrint('TextFields found: ${textFields.evaluate().length}');
      debugPrint('Send icons found: ${icons.evaluate().length}');
      debugPrint('Menu icons found: ${menuIcons.evaluate().length}');

      // This test should pass - we're just debugging
      expect(scaffolds, findsAtLeastNWidgets(1));
    });
  });
}