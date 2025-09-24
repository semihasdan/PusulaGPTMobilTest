# 🏥 Pusula - Advanced Medical AI Chat Platform

A sophisticated Flutter-based medical AI chat application featuring multiple specialized AI models, glassmorphism UI design, and comprehensive multilingual support.

## 🌟 Features Overview

### 🤖 Multi-Model AI System
- **PusulaGPT**: General medical AI assistant for comprehensive health queries
- **ComedGPT**: Specialized emergency medicine AI for clinical scenarios  
- **MedDiabet**: Diabetes management specialist for targeted care
- **Dynamic Model Switching**: Seamless switching between AI models with conversation context preservation

### 🎨 Modern UI/UX Design
- **Glassmorphism Interface**: Sophisticated frosted glass effects with blur and transparency
- **Bubble-less Chat Design**: Clean, minimalist message display without traditional chat bubbles
- **Floating Elements**: Glassmorphic header and input areas that float above animated backgrounds
- **Custom Animations**: Orbital loading animations and smooth transitions throughout

### 🌍 Comprehensive Internationalization
- **4 Language Support**: English, Turkish, Arabic (RTL), and Russian
- **Dynamic Localization**: Model-aware placeholder text (e.g., "Ask PusulaGPT anything...")
- **Cultural Adaptation**: Proper text direction and formatting for each language

### 💬 Advanced Chat Features
- **Real-time Messaging**: Instant message delivery with typing indicators
- **Message Feedback System**: Like/dislike functionality with detailed feedback collection
- **Response Regeneration**: Re-generate AI responses for better answers
- **Copy to Clipboard**: Easy sharing of AI responses
- **Conversation History**: Persistent chat sessions with recency-based sorting

### 🔧 Technical Architecture
- **Flutter Framework**: Cross-platform mobile and web application
- **Riverpod State Management**: Robust, scalable state management solution
- **Clean Architecture**: Feature-based modular structure with clear separation of concerns
- **Provider Pattern**: Efficient data flow and dependency injection

## 🏗️ Project Structure

```
lib/
├── core/                          # Core functionality and shared resources
│   ├── localization/             # Multi-language support
│   ├── models/                   # Data models (ChatMessage, AiModel, etc.)
│   ├── providers/                # Riverpod state providers
│   ├── repositories/             # Data access layer
│   ├── theme/                    # App theming and colors
│   └── widgets/                  # Reusable UI components
│       ├── animated_gradient_background.dart
│       ├── glassmorphic_container.dart
│       └── orbital_loading_animation.dart
├── features/                     # Feature-based modules
│   ├── auth/                     # Authentication system
│   │   └── presentation/
│   ├── chat/                     # Chat functionality
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   │   ├── chat_screen.dart
│   │   │   │   └── new_chat_screen.dart
│   │   │   └── widgets/
│   │   │       ├── ai_response_item.dart
│   │   │       ├── user_prompt_item.dart
│   │   │       ├── new_chat_input_area.dart
│   │   │       ├── new_chat_header.dart
│   │   │       └── typing_indicator.dart
│   └── landing/                  # Landing page features
└── main.dart                     # Application entry point
```

## 🎯 Key Components

### Chat Interface Components

#### 1. **NewChatScreen** - Main Chat Interface
- Stack-based layout with floating glassmorphic elements
- Animated gradient background
- Real-time message updates with auto-scrolling
- Model-aware conversation management

#### 2. **UserPromptItem** - User Message Display
- Clean, bubble-less design with right-aligned avatar
- Left-aligned message text for optimal readability
- Smooth fade-in animations

#### 3. **AIResponseItem** - AI Response Display  
- Streamlined layout without thinking process clutter
- Interactive action toolbar with feedback system
- Copy, like/dislike, and regenerate functionality

#### 4. **NewChatInputArea** - Message Input
- Dynamic, localized placeholder text based on selected AI model
- Custom orbital loading animation during message processing
- Simplified design without double borders

#### 5. **NewChatHeader** - Floating Header
- Glassmorphic design with model selector
- Real-time model switching with visual feedback
- Hamburger menu integration

### Core Widgets

#### 1. **GlassmorphicContainer** - Reusable Glass Effect
```dart
GlassmorphicContainer(
  borderRadius: 20.0,
  blurIntensity: 15.0,
  backgroundColor: Colors.black.withOpacity(0.25),
  borderColor: Colors.white.withOpacity(0.15),
  child: YourWidget(),
)
```

#### 2. **OrbitalLoadingAnimation** - Custom Loading Indicator
- Satellite dot orbiting around central send icon
- Configurable size, color, and animation duration
- Smooth, engaging visual feedback during loading states

#### 3. **AnimatedGradientBackground** - Dynamic Background
- Subtle animated gradient effects
- Low opacity to allow glassmorphic elements to shine
- Performance-optimized rendering

## 🔄 State Management

### Providers Architecture

#### 1. **ChatProvider** - Core Chat State
```dart
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isAiTyping;
  final String? error;
}
```

#### 2. **SelectedModelProvider** - AI Model Management
- Current model selection
- Model switching logic
- Conversation context preservation

#### 3. **ConversationsProvider** - Chat History
- Persistent conversation storage
- Recency-based sorting
- CRUD operations for chat sessions

## 🌐 Internationalization

### Supported Languages
- **English (en)**: Default language with full feature support
- **Turkish (tr)**: Complete localization including model-specific placeholders
- **Arabic (ar)**: RTL support with proper text direction
- **Russian (ru)**: Cyrillic character support

### Dynamic Localization Examples
```dart
// English: "Ask PusulaGPT anything..."
// Turkish: "PusulaGPT'e sor..."
// Arabic: "اسأل PusulaGPT أي شيء..."
// Russian: "Спросите PusulaGPT о чем угодно..."
```

## 🎨 Design System

### Color Palette
```dart
class AppTheme {
  static const primaryBlue = Color(0xFF2196F3);
  static const accentPurple = Color(0xFF9C27B0);
  static const darkBackground = Color(0xFF121212);
  static const darkCard = Color(0xFF1E1E1E);
  static const lightText = Color(0xFFE0E0E0);
  static const mediumText = Color(0xFFBDBDBD);
}
```

### Glassmorphism Parameters
- **Blur Intensity**: 15.0 for optimal frosted glass effect
- **Background Opacity**: 25% for perfect transparency balance
- **Border Opacity**: 15% for subtle edge highlighting
- **Border Radius**: 20.0-30.0 for modern rounded corners

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/your-username/pusula.git
cd pusula
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the application**
```bash
# For development
flutter run

# For web
flutter run -d chrome

# For production build
flutter build apk
flutter build web
```

### Configuration

1. **Localization Setup**
   - Language files located in `assets/localization/`
   - Add new languages by creating corresponding JSON files
   - Update `AppLocalizations` class for new language support

2. **AI Model Configuration**
   - Models defined in `lib/core/models/ai_model.dart`
   - Add new models by extending the `availableModels` list
   - Update logos in `assets/logo/` directory

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart
```

### Test Coverage
- Unit tests for core business logic
- Widget tests for UI components
- Integration tests for complete user flows

## 📱 Platform Support

### Mobile Platforms
- **iOS**: Full native performance with platform-specific optimizations
- **Android**: Material Design integration with custom theming

### Web Platform
- **Progressive Web App**: Responsive design for desktop and mobile browsers
- **WebAssembly**: High-performance rendering for complex animations

## 🔧 Development Guidelines

### Code Style
- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Implement proper error handling
- Add comprehensive documentation

### Architecture Principles
- **Single Responsibility**: Each class has one clear purpose
- **Dependency Injection**: Use Riverpod for clean dependency management
- **Immutable State**: Prefer immutable data structures
- **Feature Modules**: Organize code by feature, not by layer

### Performance Considerations
- Optimize widget rebuilds with proper keys
- Use const constructors where possible
- Implement efficient list rendering for large datasets
- Monitor memory usage in animation-heavy screens

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Review Process
- All changes require peer review
- Automated tests must pass
- Follow established coding standards
- Update documentation for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for excellent state management
- Material Design for UI/UX inspiration
- Open source community for continuous support

## 📞 Support

For support, email support@pusula.com or join our Slack channel.

---

**Built with ❤️ using Flutter**