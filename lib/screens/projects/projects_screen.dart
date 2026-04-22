import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/database_provider.dart';
import '../../providers/projects_provider.dart';
import '../../providers/inbox_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/smooth_scroll.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(allProjectsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Text('Projects', style: AppTextStyles.pageTitle),
        ),
        Expanded(
          child: projectsAsync.when(
            loading: () => const _ShimmerList(),
            error: (e, _) => Center(
              child: Text(
                'Something went wrong: $e',
                style: AppTextStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
            ),
            data: (projects) => _ProjectList(projects: projects),
          ),
        ),
      ],
    );
  }
}

// ── Project list ─────────────────────────────────────────────────────────────

class _ProjectList extends ConsumerStatefulWidget {
  const _ProjectList({required this.projects});

  final List<Item> projects;

  @override
  ConsumerState<_ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends ConsumerState<_ProjectList> {
  int? _hoveredId;

  Future<void> _insert(String title) async {
    await ref.read(appDatabaseProvider).projectsDao.insertProject(title);
  }

  @override
  Widget build(BuildContext context) {
    final projects = widget.projects;
    final itemCount = projects.isEmpty ? 2 : projects.length + 1;

    return SmoothListView.builder(
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (projects.isEmpty) {
          if (index == 0) return const _EmptyState();
          return _CaptureRow(onSubmit: _insert);
        }

        if (index == projects.length) {
          return _CaptureRow(onSubmit: _insert);
        }

        final project = projects[index];
        return _ProjectRow(
          project: project,
          hovered: _hoveredId == project.id,
          onHoverChanged: (on) =>
              setState(() => _hoveredId = on ? project.id : null),
          onTap: () => context.go('/projects/${project.id}'),
        );
      },
    );
  }
}

// ── Project row ──────────────────────────────────────────────────────────────

class _ProjectRow extends ConsumerWidget {
  const _ProjectRow({
    required this.project,
    required this.hovered,
    required this.onHoverChanged,
    required this.onTap,
  });

  final Item project;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(projectItemsProvider(project.id));
    final count = itemsAsync.maybeWhen(
      data: (p) => p.items.length,
      orElse: () => null,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          color: hovered ? AppColors.hoverBackground : AppColors.background,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              // Folder icon with accent colour dot.
              SizedBox(
                width: 20,
                height: 20,
                child: Stack(
                  children: [
                    const Icon(
                      Icons.folder_outlined,
                      size: 18,
                      color: AppColors.muted,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 1,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(project.title, style: AppTextStyles.itemTitle),
              ),
              if (count != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$count', style: AppTextStyles.itemMeta),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Capture row ──────────────────────────────────────────────────────────────

class _CaptureRow extends StatefulWidget {
  const _CaptureRow({required this.onSubmit});

  final void Function(String title) onSubmit;

  @override
  State<_CaptureRow> createState() => _CaptureRowState();
}

class _CaptureRowState extends State<_CaptureRow> {
  bool _expanded = false;
  bool _promptHovered = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() => _expanded = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) widget.onSubmit(title);
    _controller.clear();
    setState(() => _expanded = false);
  }

  void _cancel() {
    _controller.clear();
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _promptHovered = true),
        onExit: (_) => setState(() => _promptHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _expand,
          child: Container(
            color: _promptHovered
                ? AppColors.hoverBackground
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                const Icon(Icons.add, size: 16, color: AppColors.muted),
                const SizedBox(width: AppSpacing.sm),
                Text('New project', style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: Icon(
              Icons.folder_outlined,
              size: 18,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  _cancel();
                }
              },
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: AppTextStyles.itemTitle,
                decoration: const InputDecoration(
                  hintText: 'Project name',
                  hintStyle: AppTextStyles.bodyMuted,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => _submit(),
                textInputAction: TextInputAction.done,
              ),
            ),
          ),
          GestureDetector(
            onTap: _submit,
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Icon(Icons.send, size: 16, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Center(
        child: Text('No projects yet', style: AppTextStyles.bodyMuted),
      ),
    );
  }
}

// ── Shimmer placeholders ─────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return SmoothListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 4,
      itemBuilder: (context, _) => const _ShimmerRow(),
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  const _ShimmerRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 24,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
