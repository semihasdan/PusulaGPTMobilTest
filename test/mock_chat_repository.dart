import 'package:mocktail/mocktail.dart';
import 'package:pusula/core/models/ai_model.dart';
import 'package:pusula/core/models/chat_message.dart';
import 'package:pusula/core/repositories/chat_repository.dart';

class MockChatRepository extends Mock implements ChatRepository {
  final Map<String, List<ChatMessage>> _conversationData = {};
  final Map<String, int> _currentPage = {};
  final Map<String, bool> _endOfHistory = {};
  Duration networkDelay = const Duration(milliseconds: 100);
  bool shouldSimulateErrors = false;

  // Configure test data
  void setConversationData(String conversationId, List<ChatMessage> messages) {
    _conversationData[conversationId] = messages;
    _currentPage[conversationId] = 1;
    _endOfHistory[conversationId] = false;
  }

  void setNetworkDelay(Duration delay) {
    networkDelay = delay;
  }

  void enableErrorSimulation(bool enabled) {
    shouldSimulateErrors = enabled;
  }

  // Override repository methods
  @override
  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 20,
  }) async {
    // Simulate network delay
    await Future.delayed(networkDelay);
    
    // Simulate errors if enabled
    if (shouldSimulateErrors) {
      throw Exception('Simulated network error');
    }
    
    // Get conversation data
    final conversationMessages = _conversationData[conversationId] ?? [];
    
    // Check if we've reached the end of history
    if (_endOfHistory[conversationId] == true) {
      return [];
    }
    
    // Calculate pagination
    final startIndex = (page - 1) * limit;
    
    // Check if we've reached the end
    if (startIndex >= conversationMessages.length) {
      _endOfHistory[conversationId] = true;
      return [];
    }
    
    // Calculate end index
    final endIndex = startIndex + limit;
    final actualEndIndex = endIndex > conversationMessages.length 
        ? conversationMessages.length 
        : endIndex;
    
    // Return the requested page of messages
    final pageMessages = conversationMessages.sublist(startIndex, actualEndIndex);
    
    // Mark end of history if this is the last page
    if (actualEndIndex >= conversationMessages.length) {
      _endOfHistory[conversationId] = true;
    }
    
    return pageMessages.reversed.toList(); // Reverse for newest-first order
  }

  @override
  Future<String> getMockResponse(String userInput, AiModel selectedModel) async {
    // Simulate network delay
    await Future.delayed(networkDelay);
    
    // Simulate errors if enabled
    if (shouldSimulateErrors) {
      throw Exception('Simulated network error');
    }
    
    // Return a mock response
    return 'This is a mock AI response to: $userInput';
  }
}