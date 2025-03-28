# Task Management Application

A Flutter application for managing tasks with real-time collaboration and push notification features. Built using Domain-Driven Design (DDD) and BLoC pattern for state management.

## Features

### 1. User Authentication
- Email and password authentication
- Secure session management
- Protected routes
- Automatic navigation based on auth state
- Sign out functionality

### 2. Task Management
- Create, read, update, and delete tasks
- Real-time task updates using Firebase Firestore
- Task status tracking (Todo, In Progress, Completed)
- Visual status indicators with color coding
- Due date management
- Task description support

### 3. Push Notifications
- Task due date reminders
- Task status change notifications
- Local notifications for foreground messages
- Background message handling
- Firebase Cloud Messaging (FCM) integration
- Notification permission handling

### 4. Modern UI/UX
- Material Design 3
- Responsive layout using ScreenUtil
- Beautiful task cards with status indicators
- Intuitive status selection
- Clean and organized task list
- Loading and error states
- Form validation

## Demo Video

Watch a demo of the application in action:

[Watch Video](https://github.com/hokshmaxx/testapp/blob/master/demo/demo.mp4)

## Architecture

The application follows Clean Architecture principles and is organized into the following layers:

### Domain Layer
- Entities (Task, User)
- Use Cases (CreateTask, UpdateTask, DeleteTask, GetTasks)
- Repository Interfaces
- Value Objects

### Data Layer
- Repository Implementations
- Data Sources (Remote)
- Models
- DTOs

### Presentation Layer
- BLoC (Business Logic Components)
- Pages
- Widgets
- State Management

### Core
- Dependency Injection
- Services (Notification)
- Utils
- Constants

## Technologies Used

- Flutter
- Firebase
  - Authentication
  - Cloud Firestore
  - Cloud Messaging
- BLoC for state management
- GetIt for dependency injection
- Injectable for dependency injection code generation
- ScreenUtil for responsive design
- Local Notifications
- HTTP for API calls

## Project Structure

```
lib/
├── core/
│   ├── di/
│   │   └── injection.dart
│   └── services/
│       └── notification_service.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   └── task/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
└── main.dart
```

## Setup Instructions

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps
   - Download and add configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Enable Cloud Messaging
   - Get the Server Key from Firebase Console

4. Run the app:
   ```bash
   flutter run
   ```

## Features Implementation Details

### Authentication
- Uses Firebase Authentication
- Implements BLoC pattern for state management
- Handles loading, error, and success states
- Provides protected routes

### Task Management
- Real-time synchronization with Firestore
- Optimistic updates for better UX
- Batch operations for multiple updates
- Status tracking with visual indicators
- Due date management with reminders

### Notifications
- Local notifications for task reminders
- FCM for remote notifications
- Background message handling
- Notification permission management
- Token management and cleanup
- Status change notifications

### UI Components
- Responsive design using ScreenUtil
- Material Design 3 components
- Custom status indicators
- Form validation
- Loading and error states
- Clean and organized layout

## License

This project is licensed under the MIT License - see the LICENSE file for details.
