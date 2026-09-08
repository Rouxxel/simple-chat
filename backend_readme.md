# simple-chat-backend

This is a comprehensive backend API service implementing **Gemini 2.5 Flash API** for an AI chatbot with full user management, chat history, and security features. It supports receiving prompts and returning AI-generated responses via REST endpoints with complete authentication and user profile management.

The backend is built using **FastAPI** with **async/await** for concurrent user support, designed to be consumed by a **Flutter frontend**, and deployed on **Render**. It handles authentication, AI prompt processing, chat history management, user preferences, and security features on the server side.

---

## ✅ Key Features

- **🤖 AI Chatbot API**: RESTful endpoints using Gemini 2.5 Flash with multiple model support
- **🔐 Complete Authentication System**: User signup, login, logout, token refresh, and password reset
- **👤 User Profile Management**: Complete profile creation, retrieval, updates, and account deletion
- **💬 Chat History Management**: Save, retrieve, delete chat conversations with title management
- **🔒 Security Features**: Public key encryption, input validation, and secure token handling
- **⚡ Async Architecture**: Full async/await implementation for concurrent user support
- **🚦 Rate Limiting**: Configurable IP-based request throttling per endpoint
- **📝 Advanced Logging**: Centralized logging system with configurable levels
- **🏗️ Modular Router Architecture**: Clean separation with organized endpoint categories
- **⚙️ Dynamic Configuration**: Comprehensive JSON-based configuration system
- **🔑 Environment Security**: All sensitive data handled via environment variables
- **🗄️ Database Integration**: Supabase integration for authentication and data persistence
- **�️ UtilityS Tools**: Encryption, validation, cache cleaning, and version checking utilities

---

## 📁 Project Structure

```
root/
│
├── .dockerignore
├── .env                    # Environment variables (local)
├── .gitignore
├── .pylintrc              # Python linting configuration
├── docker-compose.yml     # Docker composition
├── DOCKERFILE            # Docker container configuration
├── LICENSE
├── main.py               # Application entrypoint
├── private_key.pem       # RSA private key for encryption
├── public_key.pem        # RSA public key for encryption
├── render.yaml           # Deployment config for Render.com
├── requirements.txt      # Python dependencies
├── runtime.txt          # Python runtime version for deployment
├── start.sh             # Start script
├── test_gemini_models.py # Model testing utility
│
└── src/
    ├── configuration/
    │   ├── config_file.json    # Comprehensive app configuration
    │   ├── config_loader.py    # Configuration loader
    │   └── __init__.py
    │
    ├── data/
    │   └── available_models.json   # Valid AI model configurations
    │
    ├── routers/
    │   ├── ai/
    │   │   └── ai_model_call.py         # AI model interaction endpoint
    │   ├── auth/
    │   │   ├── log_in.py                # User authentication
    │   │   ├── log_out.py               # User logout
    │   │   ├── refresh_token.py         # Token refresh
    │   │   ├── reset_password.py        # Password reset
    │   │   └── sign_up.py               # User registration
    │   ├── chat/
    │   │   ├── user_chat_delete.py      # Delete chat conversations
    │   │   ├── user_chat_retrieve.py    # Retrieve chat history
    │   │   ├── user_chat_save.py        # Save chat conversations
    │   │   └── user_chat_titles_retrieve.py # Get chat titles
    │   ├── miscellaneous/
    │   │   └── easter_egg_found.py      # Easter egg endpoint
    │   ├── security/
    │   │   └── retrieve_public_key.py   # Public key retrieval
    │   ├── user_profile/
    │   │   ├── complete_profile.py      # Complete user profile
    │   │   ├── user_delete_profile.py   # Delete user account
    │   │   ├── user_exist.py            # Check user existence
    │   │   ├── user_preferences.py      # User preferences management
    │   │   └── user_retrieve_profile.py # Retrieve user profile
    │   └── root_endpoint.py             # Health check endpoint
    │
    └── utils/
        ├── custom_logger.py             # Advanced logging configuration
        ├── en_de_crypt.py              # Encryption/decryption utilities
        ├── keys_generator.py           # RSA key generation
        ├── library_version_checker.py  # Dependency version checking
        ├── limiter.py                  # Rate limiting configuration
        ├── pycache_n_logs_deleter.py   # Cache and log cleanup
        ├── request_limiter.py          # Rate limit exception handling
        └── validators.py               # Input validation utilities
```

---

## 🌍 Environment Variables

**Required Environment Variables:**
- `CHAT_API_KEY`: Gemini API key for AI responses
- `DB_KEY`: Supabase public API key for database access
- `DB_LINK`: Supabase database URL

**Optional Environment Variables:**
- `PORT`: Server port (default: 5000)
- `LOG_LEVEL`: Logging level (default: from config)

---

## ▶️ Running Locally

1. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Set environment variables** (Linux/macOS):
   ```bash
   export CHAT_API_KEY="your_gemini_api_key_here"
   export DB_KEY="your_supabase_public_key_here"
   export DB_LINK="your_supabase_url_here"
   ```

   **Windows (PowerShell):**
   ```powershell
   $env:CHAT_API_KEY="your_gemini_api_key_here"
   $env:DB_KEY="your_supabase_public_key_here"
   $env:DB_LINK="your_supabase_url_here"
   ```

3. **Run the server:**
   ```bash
   python main.py
   ```

4. **Test the setup:**
   ```bash
   python test_gemini_models.py
   ```

---

## 🚀 Deployment

- **Render.com**: Configured for deployment using `render.yaml`
- **Docker**: Full Docker support with `DOCKERFILE` and `docker-compose.yml`
- **Environment**: Set all required environment variables in your deployment platform
- **Port**: The app listens on the `PORT` environment variable (default: 5000)

---

## 📡 API Endpoints

### 🏠 Health Check
#### `GET /`
**Health check endpoint** - Confirms API operational status
- **Rate Limit**: 25 requests/minute
- **Authentication**: ❌ Not required

**Response:**
```json
{
  "message": "Backend running successfully, ready to use other endpoints"
}
```

---

### 🔐 Authentication Endpoints (`/auth`)

#### `POST /auth/sign_up_email`
**User registration with email**
- **Rate Limit**: 3 requests/minute
- **Authentication**: ❌ Not required

#### `POST /auth/log_in_email_pw`
**User login with email and password**
- **Rate Limit**: 3 requests/minute
- **Authentication**: ❌ Not required

#### `POST /auth/log_out`
**User logout**
- **Rate Limit**: 3 requests/minute
- **Authentication**: ✅ Required

#### `POST /auth/refresh_token`
**Refresh access token**
- **Rate Limit**: 2 requests/minute
- **Authentication**: ✅ Required (refresh token)

#### `POST /auth/reset_password`
**Password reset request**
- **Rate Limit**: 3 requests/minute
- **Authentication**: ❌ Not required

---

### 👤 User Profile Endpoints (`/user_profile`)

#### `POST /user_profile/complete_profile`
**Complete user profile setup**
- **Rate Limit**: 3 requests/minute
- **Authentication**: ✅ Required

#### `POST /user_profile/user_exists`
**Check if user exists**
- **Rate Limit**: 5 requests/minute
- **Authentication**: ✅ Required

#### `POST /user_profile/user_preferences`
**Update user preferences**
- **Rate Limit**: 10 requests/minute
- **Authentication**: ✅ Required

#### `POST /user_profile/user_retrieve_profile`
**Retrieve user profile data**
- **Rate Limit**: 10 requests/minute
- **Authentication**: ✅ Required

#### `POST /user_profile/user_delete_profile`
**Delete user account permanently**
- **Rate Limit**: 5 requests/minute
- **Authentication**: ✅ Required

---

### 💬 Chat Management Endpoints (`/chat`)

#### `POST /chat/user_chat_save`
**Save chat conversation**
- **Rate Limit**: 10 requests/minute
- **Authentication**: ✅ Required

#### `POST /chat/user_chat_retrieve`
**Retrieve chat history**
- **Rate Limit**: 5 requests/minute
- **Authentication**: ✅ Required

#### `POST /chat/user_chat_titles_retrieve`
**Get chat conversation titles**
- **Rate Limit**: 5 requests/minute
- **Authentication**: ✅ Required

#### `POST /chat/user_chat_delete`
**Delete chat conversation**
- **Rate Limit**: 3 requests/minute
- **Authentication**: ✅ Required

---

### 🤖 AI Endpoints (`/ai`)

#### `POST /ai/generate_ai_response`
**Generate AI response using Gemini models**

**Supported Models:**
- `gemini-2.5-flash` (default)
- `gemini-2.5-flash-lite`
- `gemini-2.5-flash-preview-09-2025`
- `gemini-2.5-flash-lite-preview-09-2025`

- **Rate Limit**: 20 requests/minute
- **Authentication**: ✅ Required

**Request Body:**
```json
{
  "prompt": "Hello, how are you?",
  "ai_model": "gemini-2.5-flash",
  "time_limit": 10.0,
  "user_id": "user-uuid-here",
  "access_token": "supabase-jwt-token"
}
```

**Parameters:**
- `prompt` (string, required): The message for the AI
- `ai_model` (string, optional): AI model name (defaults to `gemini-2.5-flash`)
- `time_limit` (float, optional): Response timeout in seconds (default: 10.0)
- `user_id` (string, required): User UUID
- `access_token` (string, required): Supabase JWT token

**Responses:**
- **200 OK:**
  ```json
  {
    "ai_answer": "Hello! How can I help you today?"
  }
  ```
- **401 Unauthorized:** Invalid token or user mismatch
- **429 Too Many Requests:** AI service quota limits
- **504 Gateway Timeout:** AI response timeout
- **500 Internal Server Error:** Unexpected error

---

### 🔒 Security Endpoints (`/security`)

#### `POST /security/retrieve_public_e_key`
**Retrieve public encryption key**
- **Rate Limit**: 15 requests/minute
- **Authentication**: ❌ Not required

---

### 🎯 Miscellaneous Endpoints (`/miscellaneous`)

#### `POST /miscellaneous/easter_egg_found`
**Easter egg discovery endpoint**
- **Rate Limit**: 15 requests/minute
- **Authentication**: ✅ Required

---

## 🔧 Configuration

The application uses a comprehensive JSON configuration system (`src/configuration/config_file.json`) that controls:

- **Default AI model and response timeouts**
- **Logging levels and file management**
- **Email validation rules**
- **Network and server settings**
- **Individual endpoint rate limits**
- **Request routing and tagging**

---

## 🛠️ Development Tools

- **`test_gemini_models.py`**: Test which Gemini models work with your API key
- **Logging**: Centralized logging with configurable levels
- **Rate Limiting**: Per-endpoint configurable rate limits
- **Input Validation**: Comprehensive input validation utilities
- **Encryption**: RSA encryption utilities for sensitive data
- **Cache Management**: Automatic cleanup of Python cache and log files

---

## 🔄 Recent Updates

- **✅ Full Async Architecture**: All endpoints converted to async/await for concurrent user support
- **✅ Gemini 2.5 Model Support**: Updated to use latest free-tier Gemini models
- **✅ Enhanced Error Handling**: Better error messages and quota limit handling
- **✅ Modular Router Structure**: Organized endpoints into logical categories
- **✅ Comprehensive Chat Management**: Full chat history and conversation management
- **✅ Advanced Security**: Encryption, validation, and secure token handling

---

## 👨‍💻 Author
**Sebastian Russo** - 2025