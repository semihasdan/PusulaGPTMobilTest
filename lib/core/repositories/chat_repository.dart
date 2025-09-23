import '../models/ai_model.dart';

class ChatRepository {
  Future<String> getMockResponse(String userInput, AiModel selectedModel) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock responses based on selected model and user input
    final responses = _getMockResponses(selectedModel);
    
    // Simple keyword-based response selection
    final lowerInput = userInput.toLowerCase();
    
    if (lowerInput.contains('hello') || lowerInput.contains('hi')) {
      return responses['greeting']!;
    } else if (lowerInput.contains('symptom') || lowerInput.contains('pain')) {
      return responses['symptoms']!;
    } else if (lowerInput.contains('medication') || lowerInput.contains('drug')) {
      return responses['medication']!;
    } else if (lowerInput.contains('emergency') || lowerInput.contains('urgent')) {
      return responses['emergency']!;
    } else {
      return responses['default']!;
    }
  }

  Map<String, String> _getMockResponses(AiModel model) {
    switch (model.id) {
      case 'pusula':
        return {
          'greeting': 'Hello! I\'m PusulaGPT, your general medical AI assistant. How can I help you today?',
          'symptoms': 'I understand you\'re experiencing symptoms. Can you describe them in more detail? When did they start?',
          'medication': 'For medication questions, I recommend consulting with your healthcare provider. I can provide general information about common medications.',
          'emergency': 'If this is a medical emergency, please contact emergency services immediately. I\'m here for general medical guidance only.',
          'default': 'Thank you for your question. As your general medical AI assistant, I\'m here to provide helpful information and guidance.',
        };
      case 'comed':
        return {
          'greeting': 'Hello! I\'m ComedGPT, specialized in emergency medicine. What urgent medical situation can I help you with?',
          'symptoms': 'In emergency medicine, rapid assessment is crucial. Can you rate the severity of your symptoms on a scale of 1-10?',
          'medication': 'For emergency medication protocols, I can provide guidance on standard treatments and contraindications.',
          'emergency': 'I\'m designed for emergency medical situations. Please describe the urgent condition you\'re dealing with.',
          'default': 'As an emergency medicine specialist, I\'m here to help with urgent medical situations and protocols.',
        };
      case 'diabet':
        return {
          'greeting': 'Hello! I\'m MedDiabet, your diabetes management specialist. How can I assist with your diabetes care today?',
          'symptoms': 'Diabetes-related symptoms can vary. Are you experiencing high or low blood sugar symptoms?',
          'medication': 'For diabetes medications like insulin or metformin, I can help with dosing guidelines and timing.',
          'emergency': 'Diabetes emergencies like DKA or severe hypoglycemia require immediate medical attention. Please seek emergency care.',
          'default': 'I\'m here to help with diabetes management, blood sugar monitoring, and lifestyle recommendations.',
        };
      default:
        return {
          'greeting': 'Hello! How can I assist you today?',
          'symptoms': 'Please describe your symptoms in detail.',
          'medication': 'I can provide general information about medications.',
          'emergency': 'For emergencies, please contact medical services.',
          'default': 'I\'m here to help with your medical questions.',
        };
    }
  }
}