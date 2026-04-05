# KOMO - Collaborative Project Management App

KOMO is a Flutter mobile app for collaborative project and task management. It uses Firebase Auth, Firestore, Cloud Functions, and Storage with BLoC state management and GetIt dependency injection.

## What It Does

- Sign up, sign in, sign out, reset passwords, and complete a profile after registration.
- Create and manage projects with member invites, project colors, icons, and deadlines.
- Organize work in a Kanban board with tasks, subtasks, tags, priorities, assignees, comments, and drag-and-drop status changes.
- Show real-time project, task, comment, and notification updates from Firestore.
- Upload avatars, manage settings, and support account deletion.

## Tech Stack

- Flutter and Dart
- flutter_bloc for state management
- get_it and injectable for dependency injection
- Firebase Auth, Firestore, Cloud Functions, and Storage
- shared_preferences for local settings
- image_picker for avatar uploads
- equatable and dartz for domain-friendly models and results

## Architecture

The app follows a clean architecture layout with feature logic in BLoCs and Firebase-backed repositories in the data layer.

```text
lib/
├── core/         theme, constants, validators, and error mapping
├── data/         Firebase models and repository implementations
├── domain/       entities and repository contracts
├── presentation/ pages, blocs, widgets, and app flows
```

The domain layer is prepared for use cases, while the current implementation keeps the application logic in BLoCs and repository classes.

## Documentation

- [Use case diagram](docs/use-case-diagram.md)
- [Entity relations diagram](docs/entity-relations-diagram.md)
- [Current diagram index](diagrams.md)
- [Current data model notes](diagrams_updated.md)

## Key App Flows

- Authentication starts in `lib/main.dart` and routes through splash, onboarding, login, signup, complete profile, and dashboard screens.
- Project data is handled through Firestore-backed repositories and streamed into the dashboard and Kanban views.
- Task details manage subtasks, comments, assignees, and notification creation.
- Project invitations and notifications are stored in Firestore and surfaced in the UI through dedicated pages.
- Password reset supports both the legacy Firebase email flow and the backend code-based flow implemented with Cloud Functions.

## Project Layout

- `lib/main.dart` defines the app bootstrap and routing table.
- `lib/injection.dart` registers Firebase-backed repository implementations.
- `lib/domain/` contains the core entities and repository interfaces.
- `lib/data/` contains Firestore, Auth, Storage, and Functions integration.
- `lib/presentation/` contains the pages, widgets, and BLoCs that drive the app.
- `firebase-functions/` contains Firestore rules and backend Cloud Functions.

## Setup

1. Install dependencies with `flutter pub get`.
2. Add the Firebase client files locally and do not commit them.
3. Generate `lib/firebase_options.dart` with FlutterFire for your Firebase project.
4. Run the app with `flutter run`.

### Firebase files

- `android/app/google-services.json`
- `ios/GoogleService-Info.plist`
- `lib/firebase_options.dart`

If you use CI, recreate the Firebase files from secure secrets before building.

## Design System

The current app theme is built around the bundled Inter font family and a palette centered on purple, teal, amber, and dark neutral surfaces.

## Notes

- Firestore collections are the source of truth for projects, tasks, subtasks, comments, notifications, and invitations.
- Kanban columns are currently represented as UI data with `todo`, `in_progress`, and `done` column IDs.
- The repository layer talks directly to Firebase services instead of a separate datasource abstraction.

Built with Flutter.
