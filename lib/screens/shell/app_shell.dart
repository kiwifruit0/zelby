import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../widgets/sidebar/app_sidebar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _titleForPath(String path) {
    if (path.startsWith('/inbox')) return 'Inbox';
    if (path.startsWith('/search')) return 'Search';
    if (path.startsWith('/calendar')) return 'Calendar';
    if (path.startsWith('/projects')) return 'Projects';
    return '';
  }

  int _bottomIndexForPath(String path) {
    if (path.startsWith('/inbox')) return 0;
    if (path.startsWith('/calendar')) return 1;
    if (path.startsWith('/projects')) return 2;
    if (path.startsWith('/search')) return 3;
    return 0;
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        context.go('/inbox');
      case 1:
        context.go('/calendar');
      case 2:
        context.go('/projects');
      case 3:
        context.go('/search');
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final title = _titleForPath(path);
    final isDesktop = MediaQuery.sizeOf(context).width > 600;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Row(
            children: [
              AppSidebar(
                onSearchFocus: () => _searchFocusNode.requestFocus(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopBar(title: title),
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
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(title: title),
            Expanded(child: widget.child),
          ],
        ),
      ),
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
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.itemTitle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.muted,
              textStyle: AppTextStyles.itemMeta,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
            ),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}
