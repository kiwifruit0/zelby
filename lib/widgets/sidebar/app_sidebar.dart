import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/inbox_provider.dart';
import '../../providers/projects_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/sidebar_counts_provider.dart';
import '../../theme/app_theme.dart';

class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
}

class AppSidebar extends ConsumerStatefulWidget {
  const AppSidebar({super.key, required this.onSearchFocus});

  final VoidCallback onSearchFocus;

  @override
  ConsumerState<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends ConsumerState<AppSidebar> {
  bool _gPending = false;
  String? _hoveredKey;
  Timer? _chordTimer;
  bool _projectsExpanded = true;

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
        LogicalKeyboardKey.keyE => _navigateTo('/events-deadlines'),
        LogicalKeyboardKey.keyC => _navigateTo('/calendar'),
        LogicalKeyboardKey.keyP => _navigateTo('/projects'),
        _ => KeyEventResult.ignored,
      };
    }

    if (event.logicalKey == LogicalKeyboardKey.keyG) {
      setState(() => _gPending = true);
      _chordTimer = Timer(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _gPending = false);
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.keyN) {
      _addInboxTask();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  KeyEventResult _navigateTo(String route) {
    context.go(route);
    return KeyEventResult.handled;
  }

  void _setHoveredKey(String key, bool isHovered) {
    setState(() {
      if (isHovered) {
        _hoveredKey = key;
      } else if (_hoveredKey == key) {
        _hoveredKey = null;
      }
    });
  }

  Future<void> _addInboxTask() async {
    final db = ref.read(appDatabaseProvider);
    await db.inboxDao.insertTask('New task');
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final countsAsync = ref.watch(sidebarCountsProvider);

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
                _AddTaskButton(
                  hoveredKey: _hoveredKey,
                  onHoverChanged: _setHoveredKey,
                  onTap: _addInboxTask,
                ),
                const SizedBox(height: AppSpacing.sm),
                _NavItemTile(
                  icon: Icons.search,
                  label: 'Search',
                  route: '/search',
                  isActive: currentPath.startsWith('/search'),
                  hoveredKey: _hoveredKey,
                  onHoverChanged: _setHoveredKey,
                ),
                _NavItemTile(
                  icon: Icons.inbox_outlined,
                  label: 'Inbox',
                  route: '/inbox',
                  count: countsAsync.value?.inboxCount,
                  isActive: currentPath.startsWith('/inbox'),
                  hoveredKey: _hoveredKey,
                  onHoverChanged: _setHoveredKey,
                ),
                _NavItemTile(
                  icon: Icons.today_outlined,
                  label: 'Today',
                  route: '/today',
                  count: countsAsync.value?.todayCount,
                  isActive: currentPath.startsWith('/today'),
                  hoveredKey: _hoveredKey,
                  onHoverChanged: _setHoveredKey,
                ),
                _NavItemTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Calendar',
                  route: '/calendar',
                  isActive: currentPath.startsWith('/calendar'),
                  hoveredKey: _hoveredKey,
                  onHoverChanged: _setHoveredKey,
                ),
                _NavItemTile(
                  icon: Icons.access_time,
                  label: 'Events & Deadlines',
                  route: '/events-deadlines',
                  count: (countsAsync.value?.eventsCount ?? 0) +
                      (countsAsync.value?.deadlinesCount ?? 0),
                  isActive: currentPath.startsWith('/events-deadlines'),
                  hoveredKey: _hoveredKey,
                  onHoverChanged: _setHoveredKey,
                ),
                const SizedBox(height: AppSpacing.lg),
                _ProjectsSection(
                  isExpanded: _projectsExpanded,
                  isActive: currentPath.startsWith('/projects'),
                  hoveredKey: _hoveredKey,
                  onHoverChanged: _setHoveredKey,
                  onToggle: () =>
                      setState(() => _projectsExpanded = !_projectsExpanded),
                  onAddProject: _addProject,
                  currentPath: currentPath,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addProject() async {
    final db = ref.read(appDatabaseProvider);
    await db.projectsDao.insertProject('New project');
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

class _AddTaskButton extends StatelessWidget {
  const _AddTaskButton({
    required this.hoveredKey,
    required this.onHoverChanged,
    required this.onTap,
  });

  final String? hoveredKey;
  final void Function(String, bool) onHoverChanged;
  final VoidCallback onTap;

  static const _key = '_addTask';

  @override
  Widget build(BuildContext context) {
    final isHovered = hoveredKey == _key;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverChanged(_key, true),
      onExit: (_) => onHoverChanged(_key, false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isHovered ? AppColors.hoverBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add,
                size: 18,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Add task',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  const _NavItemTile({
    required this.icon,
    required this.label,
    required this.route,
    this.count,
    required this.isActive,
    required this.hoveredKey,
    required this.onHoverChanged,
  });

  final IconData icon;
  final String label;
  final String route;
  final int? count;
  final bool isActive;
  final String? hoveredKey;
  final void Function(String, bool) onHoverChanged;

  bool get _isHovered => hoveredKey == route;

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive
        ? AppColors.accent.withValues(alpha: 0.12)
        : _isHovered
            ? AppColors.hoverBackground
            : Colors.transparent;

    final fgColor = isActive ? AppColors.accent : AppColors.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverChanged(route, true),
      onExit: (_) => onHoverChanged(route, false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go(route),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
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
              Icon(icon, size: 18, color: fgColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.sidebarItem.copyWith(color: fgColor),
                ),
              ),
              if (count != null && count! > 0)
                Text(
                  '$count',
                  style: AppTextStyles.sidebarItemMuted.copyWith(fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectsSection extends ConsumerWidget {
  const _ProjectsSection({
    required this.isExpanded,
    required this.isActive,
    required this.hoveredKey,
    required this.onHoverChanged,
    required this.onToggle,
    required this.onAddProject,
    required this.currentPath,
  });

  final bool isExpanded;
  final bool isActive;
  final String? hoveredKey;
  final void Function(String, bool) onHoverChanged;
  final VoidCallback onToggle;
  final VoidCallback onAddProject;
  final String currentPath;

  static const _headerKey = '_projectsHeader';

  bool get _isHeaderHovered => hoveredKey == _headerKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(allProjectsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        if (isExpanded)
          projectsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (projects) {
              final active =
                  projects.where((p) => p.deletedAt == null).toList();
              if (active.isEmpty) return const SizedBox.shrink();
              return _buildProjectList(active);
            },
          ),
      ],
    );
  }

  Widget _buildHeader() {
    final bgColor = isActive
        ? AppColors.accent.withValues(alpha: 0.12)
        : _isHeaderHovered
            ? AppColors.hoverBackground
            : Colors.transparent;

    final fgColor = isActive ? AppColors.accent : AppColors.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverChanged(_headerKey, true),
      onExit: (_) => onHoverChanged(_headerKey, false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
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
              Icon(
                Icons.folder_outlined,
                size: 16,
                color: fgColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Projects',
                  style: AppTextStyles.sidebarHeader.copyWith(color: fgColor),
                ),
              ),
              if (_isHeaderHovered) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onAddProject,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: fgColor,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
              ],
              if (_isHeaderHovered || isActive)
                Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 18,
                  color: fgColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectList(List<Item> projects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: projects.map((project) {
        final projectId = project.id;
        final projectRoute = '/projects/$projectId';
        final isProjectActive = currentPath == projectRoute;

        return _ProjectItemTile(
          key: ValueKey(projectId),
          project: project,
          route: projectRoute,
          isActive: isProjectActive,
          hoveredKey: hoveredKey,
          onHoverChanged: onHoverChanged,
        );
      }).toList(),
    );
  }
}

class _ProjectItemTile extends StatelessWidget {
  const _ProjectItemTile({
    super.key,
    required this.project,
    required this.route,
    required this.isActive,
    required this.hoveredKey,
    required this.onHoverChanged,
  });

  final Item project;
  final String route;
  final bool isActive;
  final String? hoveredKey;
  final void Function(String, bool) onHoverChanged;

  bool get _isHovered => hoveredKey == route;

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive
        ? AppColors.accent.withValues(alpha: 0.12)
        : _isHovered
            ? AppColors.hoverBackground
            : Colors.transparent;

    final fgColor = isActive ? AppColors.accent : AppColors.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverChanged(route, true),
      onExit: (_) => onHoverChanged(route, false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go(route),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
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
              const SizedBox(width: AppSpacing.md + 2),
              Text(
                '#',
                style: TextStyle(
                  fontSize: 14,
                  color: fgColor.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  project.title,
                  style: AppTextStyles.sidebarItem.copyWith(color: fgColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
