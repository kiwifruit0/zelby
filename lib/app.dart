import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/inbox/inbox_screen.dart';
import 'screens/scheduled/scheduled_screen.dart';
import 'screens/shell/app_shell.dart';
import 'theme/app_theme.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/inbox',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/inbox',
          builder: (context, state) => const InboxScreen(),
        ),
        GoRoute(
          path: '/scheduled',
          builder: (context, state) => const ScheduledScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) =>
              const _PlaceholderPage(title: 'Search'),
        ),
        GoRoute(
          path: '/calendar',
          redirect: (context, state) => '/calendar/daily',
        ),
        GoRoute(
          path: '/calendar/daily',
          builder: (context, state) =>
              const _PlaceholderPage(title: 'Daily'),
        ),
        GoRoute(
          path: '/calendar/weekly',
          builder: (context, state) =>
              const _PlaceholderPage(title: 'Weekly'),
        ),
        GoRoute(
          path: '/calendar/monthly',
          builder: (context, state) =>
              const _PlaceholderPage(title: 'Monthly'),
        ),
        GoRoute(
          path: '/projects',
          builder: (context, state) =>
              const _PlaceholderPage(title: 'Projects'),
        ),
        GoRoute(
          path: '/projects/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return _PlaceholderPage(title: 'Project $id');
          },
        ),
      ],
    ),
  ],
);

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
    return Center(
      child: Text(title, style: AppTextStyles.bodyMuted),
    );
  }
}
