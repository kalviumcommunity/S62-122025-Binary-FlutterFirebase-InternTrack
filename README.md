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
