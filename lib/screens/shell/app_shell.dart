import 'package:flutter/foundation.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  int _bottomIndexForPath(String path) {
    if (path.startsWith('/inbox')) return 0;
    if (path.startsWith('/today')) return 1;
    if (path.startsWith('/upcoming')) return 2;
    return 3;
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        context.go('/inbox');
      case 1:
        context.go('/today');
      case 2:
        context.go('/upcoming');
      case 3:
        _scaffoldKey.currentState?.openDrawer();
    }
  }

  Widget _wrapContent(Widget child, String path) {
    final isFullWidth = path.startsWith('/calendar/daily') ||
        path.startsWith('/calendar/weekly') ||
        path.startsWith('/calendar/monthly') ||
        path == '/calendar';

    if (isFullWidth) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final layoutState = ref.watch(layoutProvider);
    final layoutNotifier = ref.read(layoutProvider.notifier);

    final isMobile = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final isWide = MediaQuery.sizeOf(context).width > 600;
    final showSidebar = !isMobile && isWide && layoutState.sidebarVisible;

    if (!isMobile) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        drawer: isWide
            ? null
            : Drawer(
                child: AppSidebar(
                  onSearchFocus: () => _searchFocusNode.requestFocus(),
                  showToggle: false,
                ),
              ),
        body: SafeArea(
          child: Stack(
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: showSidebar ? 260.0 : 0.0,
                    decoration: const BoxDecoration(),
                    clipBehavior: Clip.hardEdge,
                    child: AppSidebar(
                      onSearchFocus: () => _searchFocusNode.requestFocus(),
                      onToggle: layoutNotifier.toggleSidebar,
                      showToggle: true,
                    ),
                  ),
                  Expanded(child: _wrapContent(widget.child, path)),
                ],
              ),
              if (!showSidebar)
                Positioned(
                  left: 4,
                  top: 4,
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    color: AppColors.muted,
                    splashRadius: 20,
                    onPressed: isWide
                        ? layoutNotifier.toggleSidebar
                        : () => _scaffoldKey.currentState?.openDrawer(),
                    tooltip: 'Show sidebar',
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      body: SafeArea(bottom: false, child: _wrapContent(widget.child, path)),
      drawer: Drawer(
        child: AppSidebar(
          onSearchFocus: () => _searchFocusNode.requestFocus(),
          showToggle: false,
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
            icon: Icon(Icons.today_outlined),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            label: 'Upcoming',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
