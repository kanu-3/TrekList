# TrekList

TrekList is a lightweight Flutter task & event management app built for trekkers and outdoor groups.  
It provides a calendar-focused UI, task creation/editing, and Riverpod-based state management to help plan and execute treks.

---

## What’s included:
- Flutter app (Android / iOS / Web)
- Calendar view using `table_calendar`
- Task CRUD with Riverpod providers
- Due date filtering

## Trade-offs & rationale:
### What I prioritized:
1. Fast iteration & UX: Clean UI and calendar interactions.
2. Simplicity: Local data + DAO instead of full backend to get a working MVP quickly.
3. Testability: Separation of providers and data layer for easier unit tests.

### Known limitations:
1. No cloud sync: Local only — multi-device sync requires backend (Supabase/Firebase).
2. No push notifications: Useful for reminders but needs FCM / platform setup.
3. No user authentication: For team features or verified postings, an auth layer would be needed.

## Project structure:
TrekList/
├─ android/
├─ ios/
├─ lib/
│  ├─ main.dart
│  ├─ data/
│  │  └─ database/         # local DAOs and DB helper
│  ├─ provider/
│  │  ├─ listprovider.dart
│  │  └─ taskprovider.dart
│  └─ screens/
│     ├─ mainscreens/
│     │  ├─ homescreen.dart
│     │  ├─ taskscreen.dart
│     │  └─ taskeditorscreen.dart
│     └─ splashscreens/
└─ pubspec.yaml

## Architecture:
1. Presentation: Flutter UI with screens under lib/screens/.
2. State management: Riverpod — chosen for simple, scalable, testable state handling.
3. Data layer: Simple local DAO pattern (lib/data/database/*) — easy to swap for a remote DB later.
4. Calendar: table_calendar package — battle-tested calendar UI for Flutter.

## Chosen ice to haves:
1. Tag management with color chips; multi-tag filter.
2. “Due soon” smart section (next 48h).

## Extra feature:
1. Calender view
2. Tasks organized in lists

## Future features add on:
1. Light/Dark theme (persist choice).
2. Small animations for completion/transitions.
3. Authentication and profile section
4. Smart Reminders & Notifications
5. Group Planning & Collaboration
6. Progress Tracking & Analytics
7. Notes, Journals & Photo Logs
8. Personalization & Themes
