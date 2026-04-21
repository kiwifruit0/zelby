import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

/// Intent dispatched when the user presses '/' to focus search.
/// Exposed so AppShell can wire up the search field's FocusNode via Actions.
class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
}

class AppSidebar extends StatefulWidget {
  const AppSidebar({super.key, required this.onSearchFocus});

  final VoidCallback onSearchFocus;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  // Tracks whether a 'g' chord prefix is pending (for g+i, g+c, g+p).
  bool _gPending = false;
  String? _hoveredRoute;
  Timer? _chordTimer;

  @override
  void dispose() {
    _chordTimer?.cancel();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (_gPending) {
      _chordTimer?.cancel();
      setState(() => _gPending = false);
      return switch (event.logicalKey) {
        LogicalKeyboardKey.keyT => _navigateTo('/today'),
        LogicalKeyboardKey.keyI => _navigateTo('/inbox'),
        LogicalKeyboardKey.keyC => _navigateTo('/calendar'),
        LogicalKeyboardKey.keyP => _navigateTo('/projects'),
        _ => KeyEventResult.ignored,
      };
    }

    if (event.logicalKey == LogicalKeyboardKey.keyG) {
      setState(() => _gPending = true);
      // Auto-cancel the pending chord after 600 ms with no follow-up key.
      _chordTimer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _gPending = false);
      });
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  KeyEventResult _navigateTo(String route) {
    context.go(route);
    return KeyEventResult.handled;
  }

  void _setHoveredRoute(String route, bool isHovered) {
    setState(() {
      if (isHovered) {
        _hoveredRoute = route;
      } else if (_hoveredRoute == route) {
        _hoveredRoute = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.slash): FocusSearchIntent(),
      },
      child: Actions(
        actions: {
          FocusSearchIntent: CallbackAction<FocusSearchIntent>(
            onInvoke: (_) {
              widget.onSearchFocus();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: Container(
            width: 260,
            decoration: const BoxDecoration(
              color: AppColors.sidebarBackground,
              border: Border(right: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SidebarHeader(),
                _NavItemTile(
                  icon: Icons.search,
                  label: 'Search',
                  isActive: currentPath.startsWith('/search'),
                  isHovered: _hoveredRoute == '/search',
                  onHoverChanged: (hovered) =>
                      _setHoveredRoute('/search', hovered),
                  onTap: () => context.go('/search'),
                ),
                _NavItemTile(
                  icon: Icons.inbox_outlined,
                  label: 'Inbox',
                  isActive: currentPath.startsWith('/inbox'),
                  isHovered: _hoveredRoute == '/inbox',
                  onHoverChanged: (hovered) =>
                      _setHoveredRoute('/inbox', hovered),
                  onTap: () => context.go('/inbox'),
                ),
                _NavItemTile(
                  icon: Icons.today_outlined,
                  label: 'Today',
                  isActive: currentPath.startsWith('/today'),
                  isHovered: _hoveredRoute == '/today',
                  onHoverChanged: (hovered) =>
                      _setHoveredRoute('/today', hovered),
                  onTap: () => context.go('/today'),
                ),
                _NavItemTile(
                  icon: Icons.schedule_outlined,
                  label: 'Schedule',
                  isActive: currentPath.startsWith('/schedule'),
                  isHovered: _hoveredRoute == '/schedule',
                  onHoverChanged: (hovered) =>
                      _setHoveredRoute('/schedule', hovered),
                  onTap: () => context.go('/schedule'),
                ),
                _NavItemTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Calendar',
                  isActive: currentPath.startsWith('/calendar'),
                  isHovered: _hoveredRoute == '/calendar',
                  onHoverChanged: (hovered) =>
                      _setHoveredRoute('/calendar', hovered),
                  onTap: () => context.go('/calendar'),
                ),
                _NavItemTile(
                  icon: Icons.folder_outlined,
                  label: 'Projects',
                  isActive: currentPath.startsWith('/projects'),
                  isHovered: _hoveredRoute == '/projects',
                  onHoverChanged: (hovered) =>
                      _setHoveredRoute('/projects', hovered),
                  onTap: () => context.go('/projects'),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Text(
        'ZELBY',
        style: TextStyle(
          fontSize: 11,
          color: AppColors.muted,
          letterSpacing: 1.8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  const _NavItemTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isHovered,
    required this.onHoverChanged,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isHovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive
        ? AppColors.accent.withValues(alpha: 0.12)
        : isHovered
        ? AppColors.hoverBackground
        : Colors.transparent;

    final fgColor = isActive ? AppColors.accent : AppColors.muted;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 1,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: fgColor),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: AppTextStyles.body.copyWith(color: fgColor)),
            ],
          ),
        ),
      ),
    );
  }
}
