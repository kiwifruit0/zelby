import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/layout_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/sidebar/app_sidebar.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  int _bottomIndexForPath(String path) {
    if (path.startsWith('/inbox')) return 0;
    if (path.startsWith('/today')) return 1;
    if (path.startsWith('/calendar')) return 2;
    if (path.startsWith('/upcoming')) return 3;
    if (path.startsWith('/events-deadlines')) return 4;
    if (path.startsWith('/projects')) return 5;
    if (path.startsWith('/search')) return 6;
    return 0;
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        context.go('/inbox');
      case 1:
        context.go('/today');
      case 2:
        context.go('/calendar');
      case 3:
        context.go('/upcoming');
      case 4:
        context.go('/events-deadlines');
      case 5:
        context.go('/projects');
      case 6:
        context.go('/search');
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final isDesktop = MediaQuery.sizeOf(context).width > 600;

    if (isDesktop) {
final layoutState = ref.watch(layoutProvider);
final layoutNotifier = ref.read(layoutProvider.notifier);
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: IconButton(
                  icon: Icon(
                    layoutState.sidebarVisible
                        ? Icons.view_sidebar
                        : Icons.view_sidebar_outlined,
                  ),
                  onPressed: layoutNotifier.toggleSidebar,
                  tooltip: layoutState.sidebarVisible ? 'Hide sidebar' : 'Show sidebar',
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: layoutState.sidebarVisible ? 260.0 : 0.0,
                      decoration: const BoxDecoration(),
                      clipBehavior: Clip.hardEdge,
                      child: layoutState.sidebarVisible
                          ? AppSidebar(onSearchFocus: () => _searchFocusNode.requestFocus())
                          : const SizedBox.shrink(),
                    ),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(bottom: false, child: widget.child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndexForPath(path),
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.muted,
        backgroundColor: AppColors.sidebarBackground,
        selectedLabelStyle: AppTextStyles.itemMeta,
        unselectedLabelStyle: AppTextStyles.itemMeta,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today_outlined),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            label: 'Upcoming',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'E & D',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            label: 'Projects',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}
