# Simple Chat

A comprehensive Flutter chat application that integrates with the **Gemini 2.5 Flash API** to provide an AI-powered conversational experience. The app features a complete user management system, secure authentication, and a polished chat interface with "Montgomery" - an AI assistant with the refined manner of a British butler.

### Features:
- **Multi-Screen Architecture**: Complete app flow with login, registration, profile setup, settings, and chat screens
- **User Authentication System**: Secure email-based registration and login with JWT token management
- **Profile Management**: User profiles with customizable preferences and settings
- **Session Management**: Automatic token refresh and secure session handling
- **Persistent Chat History**: Save and retrieve multiple chat conversations
- **Secure Data Storage**: Encrypted storage for sensitive user data using Flutter Secure Storage
- **Customizable UI**: Theme support with configurable colors and backgrounds
- **Audio Effects**: Sound effects for interactions and hidden easter eggs
- **Comprehensive Logging**: Detailed logging system for debugging and monitoring
- **Backend Integration**: Full REST API integration with secure endpoints

### Libraries Used:
- **cupertino_icons**: ^1.0.8 - iOS style icons
- **icons_flutter**: ^0.0.4 - Additional icon sets
- **intl**: ^0.20.2 - Internationalization and date formatting
- **google_fonts**: ^6.2.1 - Easy font management and custom typography
- **google_generative_ai**: ^0.4.6 - Gemini AI API integration
- **logger**: ^2.5.0 - Comprehensive logging and debugging
- **http**: ^1.4.0 - HTTP client for API communication
- **flutter_markdown**: ^0.6.11 - Markdown rendering support
- **path_provider**: ^2.1.1 - Access to device file system paths
- **flutter_email_sender**: ^6.0.1 - Email functionality
- **audioplayers**: ^5.2.1 - Audio playback for sound effects
- **archive**: ^4.0.7 - File compression and archiving
- **flutter_secure_storage**: ^9.2.4 - Secure data storage with encryption
- **pointycastle**: ^4.0.0 - Cryptographic operations
- **asn1lib**: ^1.6.5 - ASN.1 encoding/decoding for security

### Project Structure:
The project follows a clean, modular architecture organized into logical folders:

```
lib/
├── cache/                              # Temporary data storage
├── functionality_n_scripts/           # Core business logic
│   ├── configuration_scripts/         # App configuration management
│   ├── message_related/              # Chat message handling
│   ├── session_related/              # User session management
│   ├── standalone_methods/           # Utility and helper methods
│   └── utils/                        # Common utilities and tools
├── screens_pages/                     # UI screens and pages
│   ├── chats_page.dart              # Main chat interface
│   ├── complete_profile_page.dart    # Profile completion
│   ├── landing_page.dart            # App landing screen
│   ├── log_in_page.dart             # User authentication
│   ├── settings_page.dart           # App settings
│   └── sign_up_page.dart            # User registration
├── widgets_and_ui_elements/          # Reusable UI components
└── main.dart                         # Application entry point

assets/
├── audio/                            # Sound effects and audio files
├── color_list.json                   # Color configuration
├── config_file.json                  # Main app configuration
└── countries_list.json               # Country data for forms

fonts/                                # Custom font files
images/                               # App images and backgrounds
```

### Backend Integration:
The app connects to a secure backend service deployed on Render with the following endpoints:
- **Authentication**: Sign up, login, logout, token refresh, password reset
- **User Management**: Profile completion, preferences, user data retrieval
- **Chat Management**: Save conversations, retrieve chat history, manage chat sessions
- **Security**: Public key retrieval for encryption
- **AI Integration**: Secure AI response generation

### Technical Highlights:
- **Security First**: End-to-end encryption for sensitive data, secure token management
- **Responsive Design**: Adaptive UI that works across different screen sizes
- **Error Handling**: Comprehensive error handling and user feedback
- **Performance Optimized**: Efficient state management and resource usage
- **Configurable**: JSON-based configuration system for easy customization
- **Extensible Architecture**: Modular design allows for easy feature additions

### Current Features Implemented:
✅ **User Authentication System** - Complete registration and login flow  
✅ **Database Integration** - User data persistence and management  
✅ **Multiple AI Model Support** - Currently using Gemini 2.5 Flash only  
✅ **Chat History** - Save and retrieve conversation history  
✅ **Profile Management** - User preferences and customization  
✅ **Security Features** - Encrypted storage and secure communications  
✅ **Audio System** - Sound effects and interactive audio elements  

### Future Improvements:
- **Additional AI Models**: Integration with ChatGPT, Claude, and other AI services
- **Enhanced UI/UX**: More customization options and themes
- **Offline Mode**: Basic functionality when internet is unavailable
- **Group Chats**: Multi-user conversation support
- **File Sharing**: Image and document sharing in conversations
- **Voice Integration**: Speech-to-text and text-to-speech capabilities

### Development Environment:
- **Flutter SDK**: ^3.5.2
- **Dart**: Latest stable version
- **Target Platforms**: Android, iOS
- **Minimum SDK**: Android API 21+ / iOS 12+

### Testing Configuration:
- **Emulator**: Pixel 8 Pro API 34
- **OS**: Android 14.0 (UpsidedownCake)
- **Physical Device**: Redmi Note 12 Pro 5G

### Getting Started:
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure your backend URL in `assets/config_file.json`
4. Run `flutter run` to start the application

### Configuration:
The app uses a comprehensive JSON configuration system located in `assets/config_file.json` that controls:
- AI behavior and personality settings
- Backend API endpoints
- UI colors and themes
- Audio settings
- Security parameters
- User defaults

**Developed by: Sebastian Russo**  
**Version**: 2.11.2  
**License**: All rights reserved © 2025 Simple Chat

### Credit:
- The **Butler** icon used in this app was created by **Freepik**. You can find it here:  
  [Butler icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/butler)
