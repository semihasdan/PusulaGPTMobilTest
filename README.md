# PusulaGPT Mobile App

A high-fidelity Flutter mobile application that replicates the design and user experience of the PusulaGPT web platform. The app features a modern, dark theme with glass morphism effects and smooth animations.

## Features

### 🎨 Design & UI

-   **Dark Theme**: Futuristic dark aesthetic with gradient backgrounds
-   **Glass Morphism**: Backdrop blur effects for modern card designs
-   **Gradient Elements**: Beautiful gradient text and buttons
-   **Smooth Animations**: Flutter Animate for scroll and interaction effects
-   **Responsive Design**: Adapts to different screen sizes

### 🏗️ Architecture

-   **Clean Architecture**: Separation of concerns with data, domain, and presentation layers
-   **State Management**: Riverpod for scalable and testable state management
-   **Navigation**: Go Router for type-safe navigation
-   **Localization**: Multi-language support (English & Turkish)

### 📱 Screens

#### 1. Landing/Marketing Screen

-   Hero section with animated gradient background
-   AI Models showcase (PusulaGPT, ComedGPT, MedDiabet)
-   Interactive screenshots gallery
-   Benefits section with feature cards
-   FAQ section with expandable tiles

#### 2. Login Screen

-   Animated gradient background
-   Form validation
-   Glass morphism design
-   Loading states and error handling
-   Glass morphism back button with blur effect

#### 3. Registration Screen

-   "Why Register?" feature showcase
-   Comprehensive registration form
-   Multi-line reference field
-   Form validation and submission
-   Glass morphism back button with blur effect

#### 4. AI Chat Screen (Complete Overhaul)

-   **Web-Replica Interface**: High-fidelity recreation of web chat interface
-   **Dynamic Branding**: Logo and branding changes based on selected AI model
-   **Custom Header**: Model selector with user status tags (Administrator, Premium, Unlimited)
-   **Mobile Sidebar Drawer**: Chat history with model logo, new chat button, and user profile
-   **Welcome Message**: Personalized greeting with user email
-   **Modern Input Area**: Redesigned input with disclaimer text
-   **Timeago Integration**: Relative timestamps for chat history (21h ago, 5d ago)
-   **User Profile Menu**: Settings and logout options in drawer footer

## Tech Stack

-   **Flutter**: Cross-platform mobile development
-   **Riverpod**: State management
-   **Go Router**: Navigation with gesture support
-   **Timeago**: Relative time formatting for chat history
-   **Multi-language Support**: English, Turkish, Arabic (RTL), Russian
-   **Flutter Animate**: Animations
-   **Google Fonts**: Typography (Inter font family)
-   **Flutter Localizations**: Internationalization

## Project Structure

```
lib/
├── core/
│   ├── localization/          # App localization
│   ├── models/               # Data models
│   ├── providers/            # Riverpod providers
│   ├── repositories/         # Data repositories
│   ├── router/              # Navigation setup
│   ├── theme/               # App theme and styling
│   └── widgets/             # Reusable widgets
├── features/
│   ├── auth/                # Authentication feature
│   │   └── presentation/
│   └── landing/             # Landing page feature
│       └── presentation/
└── main.dart               # App entry point
```

## Getting Started

### Prerequisites

-   Flutter SDK (3.9.2 or higher)
-   Dart SDK
-   iOS Simulator / Android Emulator or physical device

### Installation

1. Clone the repository
2. Install dependencies:

    ```bash
    flutter pub get
    ```

3. Run the app:
    ```bash
    flutter run
    ```

### Available Commands

-   `flutter analyze` - Run static analysis
-   `flutter test` - Run unit tests
-   `flutter build apk` - Build Android APK
-   `flutter build ios` - Build iOS app

## Key Components

### Theme System

-   Centralized color palette and typography
-   Dark theme with gradient support
-   Custom button and input field styling

### Reusable Widgets

-   **GradientText**: Text with gradient colors
-   **GlassCard**: Cards with backdrop blur effect
-   **GradientButton**: Buttons with gradient backgrounds and animations
-   **AuthFormField**: Styled form inputs
-   **GlassBackButton**: Floating back button with glass morphism effect

### State Management

-   Language switching with Riverpod
-   Authentication state management
-   Form validation and loading states

### Animations

-   Scroll-triggered animations on landing page
-   Hover/tap effects on interactive elements
-   Smooth transitions between screens
-   Animated gradient backgrounds

## Localization

The app supports multiple languages with full RTL support:

-   **English (en)**: Default language
-   **Turkish (tr)**: Complete Turkish localization
-   **Arabic (ar)**: RTL support with Arabic translations
-   **Russian (ru)**: Cyrillic script support

Language files are located in `assets/localization/` and include all UI elements. Arabic automatically enables RTL layout direction.

## API Integration

The app includes mock API integration for:

-   User authentication (login/register)
-   Form validation
-   Loading and error states

Replace the mock implementations in `lib/core/repositories/` with actual API calls for production use.

## Contributing

1. Follow the established architecture patterns
2. Maintain clean code principles
3. Add appropriate tests for new features
4. Update documentation as needed

## License

This project is part of the PusulaGPT ecosystem.
