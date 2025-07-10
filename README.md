# simple_chat

This is a simple app that implements the **Gemini 2.0 Flash API** service, allowing users to interact with an AI chatbot. The user can input queries and receive answers, much like a conversation with a person.

### Features:
- **Single Stateful Screen**: The app consists of a single stateful screen with a chatbot interface where users can ask questions and get responses.
- **No Memory**: The app does not have memory, meaning the AI cannot remember previous context of the conversation. Each query is treated independently.
- **Logging**: Used for debugging and tracking events in the app using the **logger** package.
- **Object-Oriented Programming (OOP)**: The chatbot messages are managed using OOP principles for better organization and readability.
- **API Key Management**: The API key for accessing the Gemini 2.0 Flash API is securely stored using the **.env** file.
- **Future Plans**:
    - Implement a **config file** to manage the app's color palette and other app-wide settings.
    - Add a **simple memory system** so the AI can remember the context of the conversation within a session.

### Libraries Used:
- **icons_flutter**: ^0.0.4 - Extra icons
- **flutter_dotenv**: ^5.1.0 - Loads environment variables (for API key management)
- **intl**: ^0.19.0 - Date formatting
- **google_fonts**: ^6.2.1 - Easier font management
- **google_generative_ai**: ^0.4.6 - The AI service itself
- **logger**: ^2.5.0 - For logging and debugging
- **http** (commented out) - For consuming internet resources
- **url_launcher** (commented out) - For launching URLs

### Project Structure:
The project is organized into different folders for better readability and maintainability, including:
- `utils/` - Utility functions
- `methods_functions/` - Various methods for interacting with APIs and handling data
- `configurations/` - Configuration files and settings
- `screens_pages/` - All screen or page widgets of the app
- `classes/` - Custom classes (e.g., for messages, UI components)

### Future Improvements:
- **Config File for Colors**: Plan to implement a configuration file that will control the colors and color palette of the app.
- **Memory System**: In the future, the app will be able to remember the context of the conversation within the current session.

### Emulator and Device Configuration:
- **Emulator**: Pixel 8 Pro API 34
- **OS**: UpsidedownCake 14.0
- **Physical Device**: Redmi Note 12 Pro 5G for testing

By: **Sebastian Russo**

### Credit:
- The **Butler** icon used in this app was created by **Freepik**. You can find it here:  
  [Butler icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/butler)
