       # InternTrack

## Problem Statement
College students struggle to track internship applications and mentorship feedback across multiple platforms. What kind of unified portal could streamline this process?

---

## Overview
**InternTrack** is a mobile-first application designed to centralize internship tracking and mentorship interactions into a single, structured platform. The app enables students to manage internship applications, monitor progress, and receive mentor feedback in real time—eliminating the need to juggle emails, job portals, and messaging apps.

InternTrack focuses on clarity, organization, and accessibility, helping students stay on top of their career development journey with minimal friction.

---

## Key Features
- Centralized internship application tracking  
- Real-time status updates and progress monitoring  
- Structured mentor feedback and help requests  
- Secure, role-based access for students and mentors  
- Document uploads for resumes and profiles  
- Clean, responsive, mobile-first user interface  

---

## Target Users
- **College Students** – managing multiple internship applications and mentorship interactions  
- **Mentors** – providing structured, private feedback to assigned students  

---

## Solution Highlights
- **Single Unified Dashboard**: View internships, statuses, deadlines, and feedback in one place  
- **Real-Time Data Sync**: Updates reflect instantly without manual refresh  
- **Private Mentor Collaboration**: Invite-only mentor access ensures security and relevance  
- **Scalable Architecture**: Designed to grow with increasing users and data  

---

## Tech Stack

### Frontend
- **Flutter** – Cross-platform UI framework
- **Dart** – Strongly typed, reactive programming language

### Backend & Services
- **Firebase Authentication** – Secure user sign-up and login
- **Cloud Firestore** – Real-time NoSQL database
- **Firebase Storage** – Secure file uploads and document handling

---

## Core App Components
- Authentication (Sign Up, Login, Logout)
- Student Dashboard (Internship tracking)
- Mentor Dashboard (Feedback & guidance)
- Internship CRUD operations
- Profile & document management
- Real-time database integration

---

## Functional Capabilities
- Add, update, and delete internship applications  
- Assign mentors through a private invitation system  
- Submit and view mentor feedback securely  
- Upload and access resumes/documents  
- Real-time updates across all user actions  

---

## Non-Functional Focus
- Fast UI interactions (under 200 ms)
- Secure data access with enforced rules
- Responsive layouts across device sizes
- Reliable real-time synchronization

---

## How to Run the Project
```bash
flutter pub get
flutter run
```

---

## Vision
InternTrack aims to simplify and structure the internship and mentorship experience by bringing fragmented workflows into a single, intuitive platform—empowering students to focus on growth rather than coordination.

---


 # Flutter Environment Setup and First App Run

## Steps Followed

### 1. Flutter SDK Installation
- Downloaded the Flutter SDK from the official Flutter website
- Extracted the SDK and added `flutter/bin` to the system PATH
- Verified the installation using:
  ```bash
  flutter doctor```

### 2. Development Environment Setup

- Installed Android Studio
- Ensured Android SDK, Android Platform Tools, and Android Virtual Device (AVD) Manager were installed
- Installed Flutter and Dart plugins in Android Studio
- Set up VS Code with Flutter and Dart extensions for development

### 3. Emulator Configuration

- Opened Android Studio and accessed the Device Manager
- Created a virtual device using a Pixel series phone model
- Selected an Android system image (Android 13 or above)
- Launched the emulator successfully
Verified emulator detection using:

``` flutter devices```

### 4. First Flutter App Execution

- Created a new Flutter project using:

```flutter create .```
- Ran the default Flutter counter application using:

```flutter run```

- Successfully launched the application on the Android emulator

# Setup Verification

## Flutter Doctor Output

The following screenshot confirms a healthy Flutter setup with all required dependencies installed:

![Flutter Doctor Output](images/flutter_doctor.png)

---

## Flutter App Running on Emulator

The screenshot below shows the default Flutter application running successfully on the Android emulator:

![Flutter App on Emulator](images/flutter_emulator.png)

---

## Reflection

During the setup process, I faced challenges related to emulator configuration, Gradle dependency downloads, and Android device detection. Troubleshooting these issues helped me better understand how Flutter integrates with Android tooling and the importance of correct environment setup. Completing this process has prepared me to efficiently build, test, and debug Flutter applications across devices in upcoming sprint tasks.

---

## Conclusion

The Flutter SDK, Android Studio, and Android emulator have been successfully configured, and the first Flutter application has been executed on an emulator. This confirms that the development environment is ready for further Flutter UI development and Firebase integration in subsequent sprint deliverables.

---

# Exploring Flutter & Dart Fundamentals for Cross-Platform UI Development

### Objective
To understand Flutter’s architecture, widget-based UI system, and Dart language fundamentals for creating interactive, reactive, and visually consistent mobile interfaces.

---

## Flutter Architecture
Flutter is built on a layered architecture that ensures high performance and consistent UI across platforms.

### Core Layers of Flutter

- **Framework Layer (Dart):**  
  Written entirely in Dart. This layer provides Material and Cupertino widgets, rendering, animation libraries, and gesture handling.

- **Engine Layer (C++):**  
  Built using C++. It handles rendering through the Skia graphics engine, text layout, and communication with the underlying platform via platform channels.

- **Embedder Layer:**  
  Integrates Flutter with platform-specific APIs such as Android, iOS, web, Windows, macOS, and Linux.

**Key Idea:**  
Flutter does not rely on native UI components. Instead, it renders everything itself using the Skia engine, ensuring pixel-perfect consistency across all platforms.

---

## Widget Tree in Flutter
In Flutter, everything is a widget. The UI is composed as a hierarchical widget tree.

### Types of Widgets

- **StatelessWidget:**  
  Used for static UI elements that do not change over time (e.g., labels, icons).

- **StatefulWidget:**  
  Used for dynamic UI elements that update when user interaction or data changes (e.g., counters, forms).

### Example Widget Structure
    MaterialApp  
    └── Scaffold  
        ├── AppBar  
        └── Column  
            ├── Text  
            └── FloatingActionButton  

Hot Reload allows instant UI updates without restarting the app.

---

## Dart Language Essentials
Dart is a modern, object-oriented, and strongly typed language optimized for UI development.

### Core Dart Concepts

- Classes and Objects  
- Type Inference  
- Null Safety  
- Async and Await  

These features make Dart ideal for Flutter’s reactive programming model.

---

## Reactive UI with setState()
Flutter follows a reactive UI paradigm. When the state changes, Flutter rebuilds only the affected widgets.

Using `setState()`:
- Notifies Flutter that data has changed
- Triggers an efficient UI re-render
- Ensures smooth and responsive user interactions

---

## Screenshots
Screenshots of the running Flutter app and the counter interaction below.

![Flutter App Screenshot](images/flutter_counter_app.png)

---

## Project Structure Overview

The Flutter project follows a modular and scalable folder structure.  
Detailed explanations of each folder and file can be found in [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md).

---

### Folder Structure

![Project Structure](images/project_structure.png)

## Reflection on Folder Structure

Understanding the role of each Flutter folder helps maintain clean and organized code. A clear structure makes collaboration easier by allowing team members to work on separate features without conflicts.


---

## Flutter & Dart Basics


### Folder Structure

```
lib/
├── main.dart
├── screens/
├── widgets/
├── models/
├── services/
```

**Directory Explanation**
- **main.dart**: Entry point of the application that initializes the app and loads the first screen.
- **screens/**: Contains complete UI screens/pages of the app.
- **widgets/**: Reusable UI components shared across multiple screens.
- **models/**: Data structures representing core app entities.
- **services/**: Handles business logic and backend/service interactions (Firebase in later sprints).

This structure supports modular design and makes the application easier to scale and maintain.

---

### Setup Instructions

To run the project locally:

```bash
flutter pub get
flutter run
```

---

### Reflection

This task helped me understand Flutter’s widget-based architecture and how Dart enables reactive UI updates using state management. Organizing the project into screens, widgets, models, and services clarified how complex Flutter applications are built and maintained, which will help significantly in future sprints.

---



## Firebase Integration Using FlutterFire CLI

This section documents **Integrating Firebase SDKs Using FlutterFire CLI and Packages**. The objective of this unit was to connect the existing Flutter project to Firebase using the official FlutterFire CLI and prepare the application for authentication, database, and storage services in a cross-platform manner.


#### 1. Firebase Project & CLI Setup
- Ensured an existing Firebase project was available in Firebase Console
- Installed required tools:
  ```bash
  npm install -g firebase-tools
  dart pub global activate flutterfire_cli
  ```
- Verified FlutterFire CLI installation:
  ```bash
  flutterfire --version
  ```

#### 2. Firebase Authentication (CLI Login)
- Logged into Firebase using:
  ```bash
  firebase login
  ```
- Used the same Google account associated with the Firebase project

#### 3. FlutterFire CLI Configuration
- Ran the following command inside the Flutter project root:
  ```bash
  flutterfire configure
  ```
- Selected the correct Firebase project when prompted
- Allowed FlutterFire CLI to auto-detect platforms (Android by default)

This process automatically generated:
- `lib/firebase_options.dart`
- `firebase.json`
- Platform-specific Firebase configuration files

This eliminated the need for manual Firebase setup and ensured consistency across platforms.

---

### 4. Firebase Initialization in Flutter
The application entry point was updated to initialize Firebase using the generated configuration:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InternTrackApp());
}
```

This confirms that Firebase is correctly initialized for the current platform at runtime.

---

### 5. Adding Firebase SDK Packages
The following Firebase packages were added to support upcoming features:

```yaml
  firebase_core: ^4.3.0
  firebase_auth: ^6.1.3          
  cloud_firestore: ^6.1.1     
  firebase_storage: ^13.0.5
```

Dependencies were installed using:
```bash
flutter pub get
```

These SDKs are now ready to be used for:
- User authentication
- Real-time database operations
- Media and file storage

---

### 6. Verification
- Ran the application using:
  ```bash
  flutter run
  ```
- Confirmed successful build and launch on Android emulator
- Verified Firebase initialization logs in the terminal
- Confirmed the app appears under **Firebase Console → Project Settings → Your Apps**

---

## Screenshots

1. **FlutterFire CLI Configuration**
   - Terminal output showing successful execution of:
     ```bash
     flutterfire configure
     ```
     ![FlutterFire CLI Configuration Output](images/flutterfire_configure.png)
     

2. **Generated Firebase Files**
   - VS Code view showing:
     - `lib/firebase_options.dart`
     - `firebase.json`

3. **Firebase Console Verification**
   - Firebase Console screenshot showing the registered Android app
   ![Firebase Console Verification](images/firebase_console.png)

4. **Running Application**
   - App running successfully on the Android emulator after Firebase initialization
   ![App Running on Emulator](images/firebase_app_running.png)

---

## Reflection

Using FlutterFire CLI significantly simplified Firebase integration by automating configuration steps that are otherwise error-prone when done manually. The CLI-based approach ensures cross-platform readiness and maintains consistent SDK versions across environments. This setup provides a strong backend foundation for implementing authentication, real-time data synchronization, and storage features in upcoming units.

---

## Understanding the Widget Tree and Flutter's Reactive UI Model

### Project Description
This demo focuses on the **InternTrack Welcome Screen**, built using Flutter to demonstrate the **widget tree structure** and **reactive UI model**. The screen allows users to toggle between *Student* and *Mentor* roles, with the UI updating automatically based on state changes.

---

### Widget Tree Hierarchy
The Welcome Screen UI is composed of nested widgets arranged in a hierarchical widget tree:

```text
MaterialApp
└── WelcomeScreen
    └── Scaffold
        └── Container (Background)
            └── Center
                └── Padding
                    └── Column (Main Content)
                        ├── AnimatedContainer (Icon with Gradient)
                        ├── Text (App Title)
                        ├── Text (Description)
                        ├── Container (Role Selection Card)
                        │   └── Column
                        │       ├── Text ("Continue as")
                        │       ├── ListTile (Student Option)
                        │       └── ListTile (Mentor Option)
                        ├── ElevatedButton (Continue)
                        └── TextButton (Skip)

```

This structure shows clear parent–child relationships between widgets.

---

### Reactive UI Behavior
- A boolean state variable controls the displayed role (Student / Mentor)
- Pressing the button triggers `setState()`
- Flutter automatically rebuilds only the affected widgets

### Before State Change
![Welcome Screen Student](images/welcome_student.png)

### After State Change
![Welcome Screen Mentor](images/welcome_mentor.png)

---

## Concept Explanation

### What is a Widget Tree?
In Flutter, everything is a widget. Widgets are arranged hierarchically in a widget tree where each widget is a node that defines part of the UI.

### How does Flutter’s reactive model work?
Flutter follows a reactive UI model where changes in application state automatically trigger UI updates using `setState()` without manual redrawing.

### Why does Flutter rebuild only parts of the UI?
Flutter efficiently rebuilds only the widgets affected by state changes instead of the entire screen, resulting in better performance and smoother UI updates.

---

## Reflection
Understanding the widget tree and Flutter’s reactive UI model made it easier to design the InternTrack welcome screen efficiently. This approach supports scalable UI development and smooth collaboration when multiple developers work on different features.

---

# Firebase Authentication (Email & Password)

## Overview
This part of the InternTrack project implements **Firebase Authentication using Email & Password** in a Flutter application.  
Firebase Auth provides a secure, scalable, and backend-free solution for handling user signups, logins, and session management.

By completing this task, the app now allows users to:
- Register a new account using email & password
- Log in securely
- Maintain authentication state across app restarts
- Log out safely
- Verify user presence in the Firebase Console

---

## Tech Stack
- **Flutter**
- **Firebase Authentication**
- **Firebase Core**
- **FlutterFire CLI**

---

## Features Implemented
- Email & Password **Signup**
- Email & Password **Login**
- Authentication state handling using `authStateChanges()`
- Secure **Logout**
- Error handling for common authentication issues
- Firebase Console verification of registered users

---

## Setup Instructions

### 1️.Enable Firebase Authentication
1. Go to **Firebase Console**
2. Navigate to **Authentication → Sign-in method**
3. Enable **Email/Password**
4. Click **Save**

---

### 2️. Add Dependencies
```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
```

Run:
```bash
flutter pub get
```

---

### 3️.Initialize Firebase
Firebase is initialized before running the app:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(InternTrackApp());
}
```

---

## Authentication Logic

### Signup
```dart
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);
```

### Login
```dart
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

### Logout
```dart
await FirebaseAuth.instance.signOut();
```

### Authentication State Handling
```dart
FirebaseAuth.instance.authStateChanges()
```

This ensures:
- Logged-in users are redirected to **HomeScreen**
- Logged-out users are redirected to **WelcomeScreen**

---

## Verification
After successful signup/login:
1. Open **Firebase Console**
2. Go to **Authentication → Users**
3. Verify that the user email appears in the list

---

## Common Errors Handled
| Error | Cause | Handling |
|-----|------|---------|
| Invalid email | Wrong format | Validation + Firebase error |
| Weak password | < 6 characters | Manual validation |
| User not found | Email not registered | Firebase error handling |
| Wrong password | Incorrect password | Firebase error handling |
| Firebase not initialized | Missing setup | Firebase initialized in `main.dart` |

---

## Reflection

### How does Firebase simplify authentication?
Firebase eliminates the need to build and manage a custom authentication backend. It handles:
- Secure credential storage
- Token management
- Session persistence
- Cross-platform authentication

### What security features make it better than custom auth?
- Industry-standard encryption
- Secure token-based sessions
- Built-in protection against common auth vulnerabilities
- Backend managed by Google

### Challenges Faced
- Understanding authentication state handling
- Managing navigation after login/logout
- Handling FirebaseAuthException cases cleanly

#  Firestore Database Design

## Project Overview

This document defines the Firestore database structure used to store all application data.

---

##  Why Firestore?
Cloud Firestore is a real-time NoSQL database provided by Firebase. It allows:
- Instant syncing of data across devices
- Offline support
- Scalable data storage
- Secure access using Firebase Authentication

It is ideal for InternTrack because:
- Internship updates need to sync instantly
- Mentor feedback should appear in real time
- Students and mentors need role-based access

---

##  Data Requirements

The InternTrack app needs to store:

- Users (students and mentors)
- User profiles
- Internship applications
- Mentor-student relationships
- Feedback messages
- Help requests
- Uploaded resumes

---

##  Firestore Collections

The database uses these top-level collections:

- `users`
- `internships`
- `mentorships`
- `feedbacks`
- `helpRequests`
- `resumes`

---

## 📁Firestore Schema

---

## 1. `users`
Stores both students and mentors.

**Path**: `users/{userId}`

| Field | Type | Description |
|------|------|------------|
| name | string | Full name |
| email | string | Login email |
| role | string | `"student"` or `"mentor"` |
| createdAt | timestamp | Account creation time |

**Sample Document**
```json
{
  "name": "Asha",
  "email": "asha@gmail.com",
  "role": "student",
  "createdAt": "2025-01-08T10:20:00Z"
}
```

## 2️.  **internships**

Each student can have multiple internship applications.

### Path
`internships/{internshipId}`

### Fields
| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `studentId` | string | Reference to users | ✅ |
| `companyName` | string | Company name | ✅ |
| `position` | string | Job title | ✅ |
| `status` | string | `applied` / `interview` / `offer` / `rejected` | ✅ |
| `appliedDate` | timestamp | Date applied | ✅ |
| `deadline` | timestamp | Optional deadline | ❌ |
| `notes` | string | Optional notes | ❌ |
| `createdAt` | timestamp | Creation time | ✅ |

### Sample Document
```json
{
  "studentId": "uid123",
  "companyName": "Google",
  "position": "Software Intern",
  "status": "applied",
  "appliedDate": "2025-01-05",
  "deadline": "2025-01-20",
  "notes": "Referred by alumni",
  "createdAt": "2025-01-05"
}
```
## 3. Mentorships Collection

This collection links **students** with **mentors**.

---

###  Path: `mentorships/{mentorshipId}`


---

###  Fields

| Field     | Type      | Description        | Required |
|-----------|-----------|--------------------|----------|
| studentId | string    | Student user ID    | ✅ |
| mentorId  | string    | Mentor user ID     | ✅ |
| status    | string    | `pending` / `active` | ✅ |
| createdAt | timestamp | Creation time      | ✅ |

---

### 📄 Sample Document

```json
{
  "studentId": "uid123",
  "mentorId": "uid456",
  "status": "active",
  "createdAt": "2025-01-06"
}

```
## 4.  Feedbacks Collection

Mentors give feedback to students about their internships and progress.

---

###  Path: `feedbacks/{feedbackId}`

---

### 📋 Fields

| Field         | Type      | Description |
|---------------|-----------|-------------|
| studentId     | string    | Student user ID |
| mentorId      | string    | Mentor user ID |
| internshipId  | string    | Related internship ID (optional) |
| message       | string    | Feedback message |
| createdAt     | timestamp | When the feedback was created |
| isRead        | boolean   | Whether the student has read the feedback |

---

### 📄 Sample Document

```json
{
  "studentId": "uid123",
  "mentorId": "uid456",
  "internshipId": "internship789",
  "message": "Your resume looks strong. Improve project section.",
  "createdAt": "2025-01-07",
  "isRead": false
}

```
## 5.  Help Requests Collection

Students ask mentors for guidance and support.

--- 
###  Path   : `helpRequests/{requestId}`

---

### 📋 Fields

| Field        | Type      | Description |
|--------------|-----------|-------------|
| studentId    | string    | Student user ID |
| mentorId     | string    | Mentor user ID |
| message      | string    | Help request message |
| response     | string    | Mentor’s reply |
| status       | string    | `pending` or `responded` |
| createdAt    | timestamp | When the request was created |
| respondedAt  | timestamp | When the mentor responded |

---

# UI - Splash Screen, Onboarding & Auth Flow with Animations

## Features Implemented

### Authentication System
- **Email/Password Authentication** with Firebase
- **User Registration** with display name support
- **Login/Signup Toggle** with smooth animations
- **Form Validation** with error handling
- **Session Management** with Firebase Auth state persistence

### Onboarding Experience
- **3-Page Onboarding Flow** showcasing key features:
  - Centralized Dashboard
  - Mentor Collaboration
  - Real-Time Updates
- **Animated Page Indicators** with gradient effects
- **Skip Functionality** for returning users
- **Smooth Page Transitions** with elastic animations
- **First-Launch Detection** using SharedPreferences

### Splash Screen
- **Animated App Logo** with rotation and scale effects
- **Floating Particles** creating dynamic background
- **Gradient Orbs** with parallax movement
- **Loading Indicator** with branded colors
- **Auto-Navigation** to appropriate screen based on user state

### UI/UX Design
- **Modern Glassmorphism** with frosted glass effects
- **Gradient Accents** throughout the interface
- **Dark/Light Theme Support** with smooth transitions
- **Animated Backgrounds** with color morphing
- **Responsive Layouts** for various screen sizes
- **Smooth Animations** using Flutter's animation system

### Architecture & Code Quality
- **Reusable Components**:
  - `AnimatedBackground` - Dynamic gradient backgrounds
  - `FloatingOrbs` - Animated gradient orbs
  - `GradientButton` - Custom gradient buttons with loading states
  - `GlassmorphicContainer` - Frosted glass containers
  - `CustomTextField` - Styled form inputs
  - `AppLogo` - Branded logo component
  - `ThemeToggleButton` - Animated theme switcher

- **Centralized Constants** for consistent spacing, colors, and timing
- **Provider Pattern** for theme management
- **Clean Code Structure** with separation of concerns

## Tech Stack

- **SharedPreferences** - Local data persistence
- **Provider Pattern** - State management
- **Material Design 3** - Design system

## Screens

1. **Splash Screen** - App initialization with animations
2. **Onboarding Screen** - First-time user experience
3. **Auth Screen** - Login and registration
4. **Home Screen** - Main dashboard (placeholder)

## Design Highlights

- **Color Palette**:
  - Primary: Black (#0A0A0A) / White (#FFFFFF)
  - Gradients: Purple (#6B4FBB), Blue (#4A90E2), Pink (#E94B8C), Orange (#FF6B35)
  
- **Typography**: 
  - Display: 36-44px, Extra Bold
  - Body: 15-17px, Medium
  - Labels: 14px, Bold

- **Animations**:
  - Background gradient morphing (8s loop)
  - Floating orbs with sine/cosine movement
  - Page transitions with fade and slide
  - Icon animations with elastic curves
  - Button hover and loading states


## Internship Tracking System

### Overview
InternTrack provides a comprehensive internship management system for students to track their applications from initial submission through final outcomes.

### Features

#### Dashboard
- **Statistics Overview**: View total applications, interviews, and offers at a glance
- **Upcoming Deadlines**: Never miss an application deadline with automatic reminders
- **Recent Activity**: Quick access to your most recent applications
- **Progress Analytics**: Track your success rate and application trends

#### Internship Management
- **Full CRUD Operations**: Create, view, edit, and delete internship applications
- **Status Tracking**: Monitor applications through 6 distinct stages:
  - Applied
  - Interviewing
  - Offered
  - Accepted
  - Rejected
  - Archived
- **Priority System**: Categorize applications by importance (High/Medium/Low)
- **Timeline**: Automatic activity tracking for all status changes
- **Rich Details**: Store location, salary, deadline, and custom notes

#### Learning & Reflection
- **Personal Reflections**: Document your thoughts and experiences
- **Learning Outcomes**: Track what you learned from each opportunity
- **Skills Tracking**: Build your skill portfolio with each application
- **Progress Reports**: View your professional development over time

#### Organization
- **Smart Filtering**: Filter by status or priority
- **Flexible Sorting**: Sort by application date, deadline, or priority
- **Archive System**: Keep completed internships for future reference
- **Search**: Quickly find specific applications

### Data Model

#### Internship
```dart
{
  id: String
  studentId: String
  company: String
  role: String
  status: InternshipStatus
  priority: Priority
  deadline: DateTime?
  appliedDate: DateTime
  description: String?
  location: String?
  salary: String?
  skillsGained: List<String>
  reflectionNotes: String?
  learningOutcomes: String?
  timeline: List<TimelineEvent>
  isArchived: bool
  archivedDate: DateTime?
}
```

### Usage

#### Adding an Internship
1. Navigate to the Internships tab
2. Tap the "Add Internship" floating action button
3. Fill in the required fields (Company, Role)
4. Optionally add location, salary, deadline, and description
5. Select status and priority
6. Tap "Add Internship"

#### Tracking Progress
1. Open any internship from the list
2. Edit status as your application progresses
3. Add reflections and learning outcomes
4. Track skills gained throughout the process
5. View the automatically generated timeline

#### Managing Archives
1. Go to Profile → Archived Internships
2. View all completed applications
3. Restore archived internships if needed
4. Analyze your historical data

### Technical Stack
- **Frontend**: Flutter with Material Design
- **State Management**: Provider
- **Backend**: Firebase Firestore
- **Authentication**: Firebase Auth
- **UI Design**: Custom glassmorphism components

### Firestore Structure
```
internships/
  └── {internshipId}
      ├── studentId: string
      ├── company: string
      ├── role: string
      ├── status: string
      ├── priority: string
      ├── deadline: timestamp
      ├── appliedDate: timestamp
      ├── timeline: array
      ├── isArchived: boolean
      └── ... other fields
```

### Security Rules
Ensure your Firestore rules allow users to only access their own data:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /internships/{internshipId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.studentId;
      allow create: if request.auth != null 
        && request.auth.uid == request.resource.data.studentId;
    }
  }
}
```

