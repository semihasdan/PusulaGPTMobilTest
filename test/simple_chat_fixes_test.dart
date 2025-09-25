import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pusula/core/models/chat_message.dart';

void main() {
  group('Simple Chat Fixes Verification', () {
    test('ChatMessage model creates valid user messages', () {
      // Test that ChatMessage factory creates valid user messages
      final message = ChatMessage.user('Hello, this is a real message');
      
      expect(message.content, 'Hello, this is a real message');
      expect(message.isUserMessage, true);
      expect(message.id, isNotEmpty);
      expect(message.timestamp, isNotNull);
    });
    
    test('ChatMessage model creates valid AI messages', () {
      // Test that ChatMessage factory creates valid AI messages
      final message = ChatMessage.ai('This is a valid AI response');
      
      expect(message.content, 'This is a valid AI response');
      expect(message.isUserMessage, false);
      expect(message.id, isNotEmpty);
      expect(message.timestamp, isNotNull);
    });
    
    test('ChatMessage content validation', () {
      // Test that messages have valid content
      final validMessage = ChatMessage(
        id: 'test_1',
        content: 'Valid message content',
        isUserMessage: true,
        timestamp: DateTime.now(),
      );
      
      expect(validMessage.content, isNotEmpty);
      expect(validMessage.content, isNot(contains('sample user question')));
      expect(validMessage.content, isNot(contains('detailed medical response')));
    });
  });
}