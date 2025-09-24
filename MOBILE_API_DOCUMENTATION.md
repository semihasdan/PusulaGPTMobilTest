# PusulaGPT Mobile API Documentation

## Base URL
```
http://127.0.0.1:5000
```

## Overview
This document provides comprehensive API documentation for mobile developers integrating with PusulaGPT. The APIs support authentication, user management, chat/messaging, and localization features.

## Authentication

### 1. Login
**POST** `/api/login`

Login with email and password to get session authentication.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "your_password"
}
```

**Response (Success):**
```json
{
  "status": "success",
  "message": "Login successful",
  "user": {
    "id": "user_id_123",
    "email": "user@example.com",
    "name": "John Doe"
  },
  "csrf_token": "csrf_token_here",
  "remember_me": false
}
```

**Response (Error):**
```json
{
  "status": "error",
  "message": "Invalid credentials"
}
```

### 2. Register
**POST** `/api/register`

Register a new user account.

**Request:**
```json
{
  "name": "John Doe",
  "email": "user@example.com",
  "password": "secure_password",
  "organization": "Hospital Name",
  "user_group": "Nursing Department",
  "department": "Emergency",
  "job_title": "Nurse",
  "reference": "REF123",
  "tenant_name": "Main Hospital",
  "facility_name": "Emergency Wing"
}
```

**Response (Success):**
```json
{
  "status": "success",
  "message": "Registration successful. Please check your email for verification."
}
```

**Response (Error):**
```json
{
  "status": "error",
  "message": "Email already exists"
}
```

### 3. Get Current User
**GET** `/api/me`

Get current authenticated user information.

**Response (Success):**
```json
{
  "status": "success",
  "user": {
    "id": "user_id_123",
    "email": "user@example.com",
    "name": "John Doe",
    "is_active": true,
    "created_at": "2024-01-01T00:00:00Z",
    "last_login": "2024-01-15T10:30:00Z"
  }
}
```

**Response (Error):**
```json
{
  "status": "error",
  "message": "Not authenticated"
}
```

### 4. Logout
**POST** `/api/logout`

Logout current user and invalidate session.

**Response:**
```json
{
  "status": "success",
  "message": "Logged out successfully"
}
```

### 5. Forgot Password
**POST** `/api/forgot-password`

Request password reset email.

**Request:**
```json
{
  "email": "user@example.com",
  "language": "tr"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Password reset email sent"
}
```

### 6. Verify Reset Token
**POST** `/api/verify-reset-token`

Verify password reset token validity.

**Request:**
```json
{
  "token": "reset_token_here"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Token is valid",
  "user_email": "user@example.com"
}
```

### 7. Reset Password
**POST** `/api/reset-password`

Reset password with valid token.

**Request:**
```json
{
  "token": "reset_token_here",
  "password": "new_secure_password"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Password reset successful"
}
```

### 8. Verify Email
**POST** `/api/verify-email`

Verify email address with verification token.

**Request:**
```json
{
  "token": "verification_token_here"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Email verified successfully"
}
```

### 9. Resend Verification Email
**POST** `/api/resend-verification-email`

Resend email verification.

**Request:**
```json
{
  "email": "user@example.com",
  "language": "tr"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Verification email sent"
}
```

## Chat & Messaging

### 1. Send Message
**POST** `/api/send_message`

Send a message to the AI assistant.

**Request:**
```json
{
  "message": "How do I take a blood sample in the Nursing module?",
  "model": "PusulaGPT",
  "conversation_id": "conv_123"
}
```

**Response (Success):**
```json
{
  "status": "success",
  "response": "To take a blood sample in the Nursing module, follow these steps: 1. Navigate to Patient Care...",
  "user_message_id": "msg_456",
  "assistant_message_id": "msg_789",
  "conversation_id": "conv_123",
  "generated_title": "Blood Sample Collection",
  "remaining_messages": "45"
}
```

**Response (Rate Limited):**
```json
{
  "status": "error",
  "message": "Daily message limit reached"
}
```

**Response (Access Denied):**
```json
{
  "status": "error",
  "response": "You do not have access to the selected model"
}
```

### 2. Get Conversations
**GET** `/api/conversations`

Get list of user's conversations.

**Response:**
```json
{
  "status": "success",
  "conversations": [
    {
      "id": "conv_123",
      "title": "Blood Sample Collection",
      "summary": "Discussion about nursing procedures",
      "model": "PusulaGPT",
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T11:45:00Z"
    },
    {
      "id": "conv_456",
      "title": "Patient Registration",
      "summary": "How to register new patients",
      "model": "ComedGPT",
      "created_at": "2024-01-14T14:20:00Z",
      "updated_at": "2024-01-14T15:10:00Z"
    }
  ]
}
```

### 3. Get Conversation Details
**GET** `/api/conversation/{conversation_id}`

Get messages for a specific conversation.

**Response:**
```json
{
  "status": "success",
  "messages": [
    {
      "id": "msg_123",
      "role": "user",
      "content": "How do I take a blood sample?",
      "created_at": "2024-01-15T10:30:00Z",
      "model": null,
      "feedback": null,
      "human_feedback": null
    },
    {
      "id": "msg_456",
      "role": "assistant",
      "content": "To take a blood sample, follow these steps...",
      "created_at": "2024-01-15T10:31:00Z",
      "model": "PusulaGPT",
      "feedback": 1,
      "human_feedback": null
    }
  ]
}
```

### 4. Get Available Models
**GET** `/api/models`

Get list of available AI models and user capabilities.

**Response:**
```json
{
  "status": "success",
  "models": [
    {
      "id": "pusulagpt",
      "name": "PusulaGPT",
      "description": "Comprehensive hospital information management system assistant"
    },
    {
      "id": "comedgpt",
      "name": "ComedGPT",
      "description": "Clinical workflow guide specializing in patient care processes"
    },
    {
      "id": "meddiabet",
      "name": "MedDiabet",
      "description": "Specialized diabetes management assistant"
    }
  ],
  "user_role": {
    "name": "customer",
    "display_name": "Customer"
  },
  "limits": {
    "daily_message_limit": 50,
    "messages_sent_today": 5,
    "unlimited_messages": false
  },
  "capabilities": {
    "advanced_models": true,
    "premium_features": false
  }
}
```

### 5. Change Model
**POST** `/api/change_model`

Change the active AI model.

**Request:**
```json
{
  "model": "ComedGPT"
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Model changed successfully"
}
```

### 6. Send Feedback
**POST** `/api/feedback`

Send feedback for an assistant message.

**Request:**
```json
{
  "message_id": "msg_456",
  "feedback": 1
}
```

**Note:** Feedback values: `1` = positive, `-1` = negative

**Response:**
```json
{
  "status": "success",
  "message": "Feedback recorded"
}
```

### 7. Send Detailed Feedback
**POST** `/api/detailed_feedback`

Send detailed feedback with corrected answer.

**Request:**
```json
{
  "message_id": "msg_456",
  "corrected_answer": "The correct procedure should include these additional steps..."
}
```

**Response:**
```json
{
  "status": "success",
  "message": "Detailed feedback recorded"
}
```

### 8. Delete Detailed Feedback
**DELETE** `/api/detailed_feedback/{message_id}`

Delete detailed feedback for a message.

**Response:**
```json
{
  "status": "success",
  "message": "Detailed feedback deleted"
}
```

## Localization

### 1. Get Translations
**GET** `/api/localization/{culture}`

Get translations for specified culture.

**Supported cultures:** `en-US`, `tr-TR`, `de-DE`, `ar-SA`, `ru-RU`

**Response:**
```json
{
  "brand": "PusulaGPT",
  "nav": {
    "models": "Models",
    "screenshots": "Screenshots",
    "benefits": "Benefits",
    "faq": "FAQ"
  },
  "hero": {
    "title1": "AI Assistants",
    "title2": "for Smarter Healthcare",
    "subtitle": "PusulaGPT revolutionizes healthcare workflows...",
    "startTrial": "Start Free Trial",
    "learnMore": "Learn More"
  },
  "auth": {
    "login": "Login",
    "signup": "Sign Up"
  }
}
```

### 2. Set Culture
**POST** `/api/localization/set-culture/{culture}`

Set user's preferred culture.

**Response:**
```json
{
  "success": true,
  "culture": "tr-TR"
}
```

## User Authentication Status

### Get Auth Status
**GET** `/api/auth/status`

Get current authentication status.

**Response (Authenticated):**
```json
{
  "isAuthenticated": true,
  "userName": "user@example.com",
  "roles": ["customer"]
}
```

**Response (Not Authenticated):**
```json
{
  "isAuthenticated": false,
  "userName": null,
  "roles": []
}
```

## Error Handling

### Common HTTP Status Codes
- `200 OK` - Success
- `400 Bad Request` - Invalid request format or parameters
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Access denied (e.g., model access restrictions)
- `404 Not Found` - Resource not found
- `409 Conflict` - Email already exists during registration
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error

### Error Response Format
```json
{
  "status": "error",
  "message": "Descriptive error message"
}
```

## Authentication Headers

### CSRF Token
Include CSRF token in headers for authenticated requests:
```
X-CSRFToken: your_csrf_token_here
```

### Cookies
Authentication is managed via HTTP cookies. Ensure your HTTP client supports cookie handling.

## Rate Limiting

Users have daily message limits based on their subscription:
- Free users: 50 messages per day
- Premium users: Unlimited messages

Check the `remaining_messages` field in chat responses to track usage.

## Security Notes

1. **HTTPS Required**: Use HTTPS in production
2. **CSRF Protection**: Include CSRF tokens for state-changing operations
3. **Cookie Security**: Ensure secure cookie handling
4. **Input Validation**: Validate all input on client side
5. **Error Handling**: Don't expose sensitive information in error messages

## Model Access

Different user roles have access to different models:
- **Customer**: Access to basic models
- **Premium**: Access to advanced models including specialized assistants

Check the `/api/models` endpoint to see available models for the current user.

## Best Practices

1. **Message Context**: Always include context in your messages for better AI responses
2. **Module Specification**: Mention the specific module or screen you're working with
3. **Error Handling**: Always handle rate limiting and access denied errors gracefully
4. **Feedback**: Encourage users to provide feedback to improve AI responses
5. **Localization**: Support multiple languages using the localization endpoints