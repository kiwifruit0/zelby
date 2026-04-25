# Zelby

A cross-platform planner app (Linux, Android, web) built with Flutter. Offline-first with Drift SQLite storage.

## Tech Stack

- Framework: Flutter (Dart)
- State: Riverpod
- Database: Drift (SQLite)
- Navigation: go_router

## Architecture

- Widgets → Providers → DAOs → Database
- No business logic in widgets
- All queries through Drift DAOs

## Object Types

- Inbox: Unscheduled tasks
- Scheduled Tasks: Start/end date tasks
- Events: Date-bounded events (auto-complete)
- Deadlines: End-date only items
- Projects: Containers for any object type

## Running and Building

```bash
flutter run -d linux

flutter build linux
```
