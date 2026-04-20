import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_theme.dart';

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/inbox'),
    GoRoute(
      path: '/inbox',
      builder: (context, state) => const _RoutePage(title: 'Inbox'),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const _RoutePage(title: 'Search'),
    ),
    GoRoute(path: '/calendar', redirect: (context, state) => '/calendar/daily'),
    GoRoute(
      path: '/calendar/daily',
      builder: (context, state) => const _RoutePage(title: 'Calendar Daily'),
    ),
    GoRoute(
      path: '/calendar/weekly',
      builder: (context, state) => const _RoutePage(title: 'Calendar Weekly'),
    ),
    GoRoute(
      path: '/calendar/monthly',
      builder: (context, state) => const _RoutePage(title: 'Calendar Monthly'),
    ),
    GoRoute(
      path: '/projects',
      builder: (context, state) => const _RoutePage(title: 'Projects'),
    ),
    GoRoute(
      path: '/projects/:id',
      builder: (context, state) {
        final projectId = state.pathParameters['id'] ?? '';
        return _RoutePage(title: 'Project $projectId');
      },
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

class _RoutePage extends StatelessWidget {
  const _RoutePage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
