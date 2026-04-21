import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/calendar/daily_calendar_screen.dart';
import 'screens/calendar/monthly_calendar_screen.dart';
import 'screens/calendar/weekly_calendar_screen.dart';
import 'screens/deadlines/deadlines_screen.dart';
import 'screens/events/events_screen.dart';
import 'screens/inbox/inbox_screen.dart';
import 'screens/projects/project_detail_screen.dart';
import 'screens/projects/projects_screen.dart';
import 'screens/schedule/schedule_screen.dart';
import 'screens/shell/app_shell.dart';
import 'screens/today/today_screen.dart';
import 'theme/app_theme.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/inbox',
  routes: [
    ShellRoute(
      pageBuilder: (context, state, child) =>
          _noTransitionPage(state, AppShell(child: child)),
      routes: [
        GoRoute(
          path: '/today',
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const TodayScreen()),
        ),
        GoRoute(
          path: '/inbox',
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const InboxScreen()),
        ),
        GoRoute(
          path: '/schedule',
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const ScheduleScreen()),
        ),
        GoRoute(
          path: '/events',
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const EventsScreen()),
        ),
        GoRoute(
          path: '/deadlines',
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const DeadlinesScreen()),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const _PlaceholderPage(title: 'Search')),
        ),
        GoRoute(
          path: '/calendar',
          redirect: (context, state) => '/calendar/daily',
        ),
        GoRoute(
          path: '/calendar/daily',
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const DailyCalendarScreen()),
        ),
        GoRoute(
          path: '/calendar/weekly',
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const WeeklyCalendarScreen()),
        ),
        GoRoute(
          path: '/calendar/monthly',
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const MonthlyCalendarScreen()),
        ),
        GoRoute(
          path: '/projects',
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const ProjectsScreen()),
        ),
        GoRoute(
          path: '/projects/:id',
          pageBuilder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return _noTransitionPage(state, ProjectDetailScreen(projectId: id));
          },
        ),
      ],
    ),
  ],
);

Page<void> _noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}

class ZelbyApp extends StatelessWidget {
  const ZelbyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'Zelby',
        theme: lightTheme,
        routerConfig: _router,
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      children: [
        Text(title, style: AppTextStyles.pageTitle),
        const SizedBox(height: AppSpacing.md),
        const Text('Coming soon', style: AppTextStyles.bodyMuted),
      ],
    );
  }
}
