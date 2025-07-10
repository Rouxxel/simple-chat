# simple_chat

This is a simple app that implements the **Gemini 2.0 Flash API** service, allowing users to interact with an AI chatbot. The user can input queries and receive answers, much like a conversation with a person.

### Features:
- **Single Stateful Screen**: The app consists of a single stateful screen with a chatbot interface where users can ask questions and get responses.
- **Memory**: The app has a rudimentary memory, the query sent to the AI api is the full current conversation for context, is prone to forget, needs changes.
- **Logging**: Used for debugging and tracking events in the app using the **logger** package.
- **Object-Oriented Programming (OOP)**: The chatbot messages are managed using OOP principles for better organization and readability.
- **Back-end connection**: The API key and actual call to AI api are stored and executed outside the app itself in a Web Service depoloyed in Render, in the future it is possible to add more endpoints for various purposes.
- **Future Plans**:
    - Implement a rudimentary connection to a database to implement log in check
    - Allow to choose from different AI models, possibly ChatGPT or Claude

### Libraries Used:
- **icons_flutter**: ^0.0.4 - Extra icons
- **intl**: ^0.19.0 - Date formatting
- **google_fonts**: ^6.2.1 - Easier font management
- **google_generative_ai**: ^0.4.6 - The AI service itself
- **logger**: ^2.5.0 - For logging and debugging
- **http**: ^1.4.0 - For consuming internet resources
- **url_launcher**(commented out): ^6.3.0   - For launching URLs
- **flutter_dotenv**(commented out): ^5.1.0 - Loads environment variables (for API key management)

### Project Structure:
The project is organized into different folders for better readability and maintainability, including:
- `utils/` - Utility functions
- `methods_functions/` - Various methods for interacting with APIs and handling data
- `configurations/` - Configuration files and settings
- `screens_pages/` - All screen or page widgets of the app
- `classes/` - Custom classes (e.g., for messages, UI components)

### Future Improvements:
- **Data base support**: Plan to implement a simple database for log in.
- **Various ai models support**: Plan to allow the user to choose different models

### Emulator and Device Configuration:
- **Emulator**: Pixel 8 Pro API 34
- **OS**: UpsidedownCake 14.0
- **Physical Device**: Redmi Note 12 Pro 5G for testing

By: **Sebastian Russo**

### Credit:
- The **Butler** icon used in this app was created by **Freepik**. You can find it here:  
  [Butler icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/butler)
