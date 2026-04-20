# Zelby Planner — Project Briefing

## Overview
Zelby is a cross-platform planner application targeting Linux desktop, Android, and web.
It is offline-first; sync will be bolted on later and should not influence current architecture decisions.

## Tech Stack
- **Framework:** Flutter (Dart)
- **State management:** Riverpod
- **Local database:** Drift (SQLite)
- **Navigation:** go_router
- **Target platforms:** Linux desktop, Android, web

## Architecture Rules
- Widgets never talk to Drift directly — always go through a Riverpod provider
- Providers never hold business logic — they expose data and call DAO methods
- DAOs own all query logic — one DAO per domain area (inbox, calendar, projects, etc.)
- Screens are dumb — they read from providers and dispatch actions, nothing else
- No business logic in the widget tree

## Project Structure
lib/
main.dart
app.dart                  # Root widget, Riverpod scope, go_router config
database/
database.dart           # Drift AppDatabase class
tables/                 # One file per table definition
daos/                   # One file per DAO
providers/                # Riverpod providers, one file per domain
models/                   # Any non-Drift data models or enums
screens/                  # One folder per screen
inbox/
calendar/
projects/
search/
widgets/                  # Shared/reusable widgets
theme/                    # Colours, typography, spacing constants

## Object Types

### Unscheduled Tasks (inbox)
- Title, optional notes
- No date
- Manually marked complete by user
- Lives in inbox until completed or assigned to a project

### Scheduled Tasks
- Title, optional notes
- Start date + end date (can have one or both)
- Manually marked complete by user

### Events
- Title, optional notes
- Start date + end date (both required)
- Automatically marked complete once end date has passed
- Cannot be manually ticked off early
- Display should reflect the dual-date nature

### Deadlines
- Title, optional notes
- End date only
- Automatically marked complete once end date has passed
- Can also be manually ticked off before end date
- Display should show a visual distinction from events (e.g. urgency indicator)

### Projects
- Title, optional notes
- Optional start date, optional end date
- Can contain any object type, including other projects (nested)
- No automatic completion — purely user-managed
- Can be used as buckets or sprint-style containers

## Database Schema Conventions
- All tables have an `id` integer primary key (autoIncrement)
- All tables have `created_at` and `updated_at` datetime columns
- Soft deletes: use a `deleted_at` nullable datetime column rather than hard deletes
- Object type is stored as a string enum column where needed
- Polymorphic project membership is handled via a `project_items` join table
  with columns: `project_id`, `item_id`, `item_type` (string enum)
- Task dependencies stored in a `task_dependencies` join table:
  `task_id`, `depends_on_id` (both reference the items table)
- Recurrence stored as an RRULE string (RFC 5545) on the parent object,
  nullable — null means no recurrence
- Recurrence instances are generated lazily at query time, not materialised into the DB

## UI Layout
- Modelled on Touring/Linear style: persistent left sidebar on desktop
- Sidebar contains: Search, Inbox, Calendar, Projects (in that order)
- On Android: sidebar collapses to bottom navigation
- On web: same as desktop
- Main content area takes remaining space

## UI Design Reference

Zelby's visual design is modelled after Todoist. Key principles:

- Sidebar: ~260px fixed, off-white background (#FAFAFA), active item has soft accent-colour tint
- Task rows: checkbox left, title, muted metadata below — no row borders, hover state only
- Quick capture: inline "+ Add item" row at bottom of each list, expands in place (no modal)
- Typography: 14px body, 12px muted section headers
- Projects: each gets a user-chosen colour dot shown in sidebar and on items

Item type visual distinctions:
- Unscheduled task: hollow circle checkbox
- Scheduled task: hollow circle with small clock icon beside metadata
- Event: hollow rounded square (cannot be ticked, shape signals this)
- Deadline: hollow circle, colour shifts amber → red as end date approaches
- Project: folder icon with colour dot

Avoid: heavy borders, card shadows, excessive whitespace, modal dialogs for common actions.
Prefer: inline interactions, subtle hover states, keyboard-first flows.

Accent colour: #D5CFF2
Background: #FAFAFA sidebar, #FFFFFF main content
Text: #202020 primary, #888888 muted

## Keyboard Shortcuts (desktop)
- `n` — new task (captures to inbox)
- `/` — focus search
- `g i` — go to inbox
- `g c` — go to calendar
- `g p` — go to projects
- `Escape` — close modal / deselect

## Calendar Views
- Monthly overview
- Weekly view
- Daily view with timeblocking (drag scheduled tasks onto time slots)
- Unscheduled tasks and notes appear in a sidebar panel within the daily view

## Notifications
- Desktop notifications before events and deadlines
- User-configurable lead time (e.g. 15 min, 1 hour, 1 day before)
- Implemented via flutter_local_notifications
- Notification schedule stored in DB and re-registered on app start

## Recurrence Rules
- Stored as RRULE strings per RFC 5545
- UI exposes simplified options: every N days, every N weeks, every N months, up to a date
- These map to RRULE strings under the hood
- Expansion logic lives in a dedicated RecurrenceService class, not in DAOs or widgets

## Coding Conventions
- Use `freezed` for immutable data classes and sealed unions where appropriate
- Use `riverpod_annotation` and code generation (`@riverpod`) for providers
- All async providers should handle loading and error states explicitly
- Prefer `AsyncValue` over raw futures in providers
- Write DAOs as Drift `DatabaseAccessor` subclasses
- No print statements — use a proper logger (e.g. `package:logging`)
- All files use snake_case naming

## Current Build Stage
[UPDATE THIS SECTION as you progress]
- [ ] Drift schema defined
- [ ] DAOs created
- [ ] Riverpod providers wired up
- [ ] App shell and navigation
- [ ] Inbox screen
- [ ] Scheduled tasks screen
- [ ] Events screen
- [ ] Deadlines screen
- [ ] Projects screen
- [ ] Calendar views
- [ ] Keyboard shortcuts
- [ ] Notifications
- [ ] Recurrence logic

