# TrekList

TrekList is a lightweight Flutter task & event management app built for trekkers and outdoor groups.  
It provides a calendar-focused UI, task creation/editing, and Riverpod-based state management to help plan and execute treks.

---

## What’s included
- Flutter app (Android / iOS / Web)
- Calendar view using `table_calendar`
- Task CRUD with Riverpod providers
- Project-ready `.gitignore`, CI workflow, and README

## Trade-offs & rationale
### What I prioritized:
1. Fast iteration & UX: Clean UI and calendar interactions.
2. Simplicity: Local data + DAO instead of full backend to get a working MVP quickly.
3. Testability: Separation of providers and data layer for easier unit tests.

### Known limitations
1. No cloud sync: Local only — multi-device sync requires backend (Supabase/Firebase).
2. No push notifications: Useful for reminders but needs FCM / platform setup.
3. No user authentication: For team features or verified postings, an auth layer would be needed.
