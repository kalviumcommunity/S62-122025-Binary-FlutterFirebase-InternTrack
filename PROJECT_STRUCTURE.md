# Flutter Project Folder Structure

## Introduction
A Flutter project follows a predefined folder structure that helps developers organize code, manage assets, and support scalable cross-platform development. Understanding the role of each folder is essential for maintaining clean code and collaborating effectively in a team.

---

## Key Folders and Files

### lib/
The core folder of the Flutter application.
- Contains all Dart source code
- `main.dart` is the entry point of the app
- Organized into subfolders like screens, widgets, services, and models

### android/
Contains Android-specific configuration and build files.
- Uses Gradle for building the Android app
- `android/app/build.gradle` defines app version, name, and dependencies

### ios/
Contains iOS-specific configuration and build files.
- Works with Xcode to build iOS apps
- `ios/Runner/Info.plist` stores app metadata and permissions

### assets/
Manually created folder for static resources.
- Stores images, fonts, and JSON files
- Must be declared in `pubspec.yaml`

### test/
Contains automated test files.
- Used for unit and widget testing
- Helps ensure app stability and correctness

### pubspec.yaml
Main configuration file of a Flutter project.
- Manages dependencies
- Declares assets and fonts
- Defines environment settings

---

## Supporting Files

- `.gitignore`: Specifies files Git should ignore
- `README.md`: Project documentation and setup guide
- `build/`: Auto-generated compiled output (not edited manually)
- `.dart_tool/` and `.idea/`: IDE and Dart tooling configuration files

---

## Folder Hierarchy (Overview)


```text
project_root/
├── android/              # Android-specific configuration and build files
├── ios/                  # iOS-specific configuration and build files
├── lib/                  # Main Dart source code
│   └── main.dart         # Application entry point
├── test/                 # Unit and widget tests
├── assets/               # Images, fonts, and static resources (manual)
│
├── web/                  # Flutter web support files
├── windows/              # Windows desktop support
├── macos/                # macOS desktop support
├── linux/                # Linux desktop support
│
├── build/                # Auto-generated build output
├── .dart_tool/           # Dart & Flutter internal tooling files
├── .idea/                # IDE configuration files
│
├── pubspec.yaml          # Dependencies, assets, and environment config
├── pubspec.lock          # Locked dependency versions
├── analysis_options.yaml # Linting and static analysis rules
├── .gitignore            # Git ignore rules
├── README.md             # Project documentation
├── PROJECT_STRUCTURE.md  # Folder structure explanation

```
---

## Reflection

Understanding the Flutter folder structure makes it easier to scale applications and divide responsibilities within a team. A clean and consistent structure reduces merge conflicts, improves readability, and allows multiple developers to work efficiently on different parts of the app.
