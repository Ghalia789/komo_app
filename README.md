# KOMO - Collaborative Project Management App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey.svg)](https://flutter.dev/)

A modern, collaborative project management mobile application built with Flutter, inspired by Trello. KOMO enables teams to manage projects efficiently through intuitive Kanban boards, real-time collaboration, and seamless task tracking.

## 🎯 Project Overview

**KOMO** is a collaborative project management mobile app (Trello-like) built with Flutter for iOS/Android. Uses Clean Architecture with BLoC pattern.

### Key Highlights
- Trello-like Kanban board interface
- Real-time collaboration via Firebase
- Custom project color palettes
- Team member invites and management
- Cross-platform native performance

## ✨ Features

- **Authentication**: Login/signup with Firebase Auth
- **Project Management**: Create projects, Kanban boards (À faire, En cours, Terminé)
- **Task Management**: Create tasks with labels, assignees, due dates
- **Team Collaboration**: Invite members, role-based permissions
- **Real-time Updates**: Live synchronization with Firestore

## 🛠 Tech Stack

- Flutter 3.x
- Dart
- flutter_bloc (state management)
- Firebase (Auth, Firestore)
- GetIt (dependency injection)
- Clean Architecture

## 🏗 Architecture

```
lib/
├── core/ (theme, constants, errors, utils)
├── data/ (models, repositories, datasources)
├── domain/ (entities, repositories, usecases)
├── presentation/ (blocs, pages, widgets)
```

Follows Clean Architecture for separation of concerns, testability, and maintainability.

## 🎨 Design System

| Color | Hex Code | Usage |
|-------|----------|-------|
| Primary | `#9600BF` | Main brand, buttons |
| Secondary | `#B85C6E` | Accent, secondary actions |
| Success | `#268060` | Success states |
| Warning | `#D4A017` | Warning states |
| Background | `#F7F5F7` | Main background |


## 🚀 Installation

1. **Clone**: `git clone <repo-url>`
2. **Install**: `flutter pub get`
3. **Configure Firebase (do not commit secrets)**:
	 - Ask a maintainer for the encrypted Firebase configs and decode them locally:
		 - `android/app/google-services.json`
		 - `ios/GoogleService-Info.plist`
	 - Generate `lib/firebase_options.dart` locally with FlutterFire:
		 - `dart pub global activate flutterfire_cli`
		 - `flutterfire configure --project=komo-1b403 --platforms=android -o lib/firebase_options.dart`
4. **Run**: `flutter run`

### CI hint (GitHub Actions)
Store the Firebase configs as base64 strings in repository secrets and recreate them during CI before building:

```bash
echo "$GOOGLE_SERVICES_JSON" | base64 -d > android/app/google-services.json
echo "$GOOGLE_SERVICE_INFO_PLIST" | base64 -d > ios/GoogleService-Info.plist
flutterfire configure --project=komo-1b403 --platforms=android -o lib/firebase_options.dart
```

## 📖 Usage

1. Complete onboarding and authentication
2. Create projects with custom colors
3. Add team members
4. Create and manage tasks in Kanban boards
5. Collaborate in real-time

---

Built with ❤️ using Flutter
