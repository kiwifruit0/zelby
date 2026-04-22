import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/daos/inbox_dao.dart';
import '../../providers/database_provider.dart';
import '../../providers/inbox_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/smooth_scroll.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(inboxTasksProvider);

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
          child: Text('Inbox', style: AppTextStyles.pageTitle),
        ),
        Expanded(
          child: tasksAsync.when(
            loading: () => const _ShimmerList(),
            error: (e, _) => Center(
              child: Text(
                'Something went wrong: $e',
                style: AppTextStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
            ),
            data: (tasks) => _TaskList(tasks: tasks),
          ),
        ),
      ],
    );
  }
}

// ── Task list ────────────────────────────────────────────────────────────────

class _TaskList extends ConsumerWidget {
  const _TaskList({required this.tasks});

  final List<Item> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SmoothListView.builder(
      padding: EdgeInsets.zero,
      itemCount: tasks.isEmpty ? 2 : tasks.length + 1,
      itemBuilder: (context, index) {
        if (tasks.isEmpty) {
          if (index == 0) {
            return const _EmptyState();
          }
          return _CaptureRow(onSubmit: (title) => _insert(ref, title));
        }

        if (index == tasks.length) {
          return _CaptureRow(onSubmit: (title) => _insert(ref, title));
        }

        return _TaskRow(
          task: tasks[index],
          onComplete: () => _complete(ref, tasks[index].id),
        );
      },
    );
  }

  Future<void> _insert(WidgetRef ref, String title) async {
    final db = ref.read(appDatabaseProvider);
    await InboxDao(db).insertTask(title);
  }

  Future<void> _complete(WidgetRef ref, int id) async {
    final db = ref.read(appDatabaseProvider);
    await InboxDao(db).markComplete(id);
  }
}

// ── Individual task row ──────────────────────────────────────────────────────

class _TaskRow extends StatefulWidget {
  const _TaskRow({required this.task, required this.onComplete});

  final Item task;
  final VoidCallback onComplete;

  @override
  State<_TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<_TaskRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final created = widget.task.createdAt;
    final dateLabel =
        '${created.month}/${created.day}/${created.year.toString().substring(2)}';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        color: _hovered ? AppColors.hoverBackground : AppColors.background,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hollow circle checkbox
            GestureDetector(
              onTap: widget.onComplete,
              child: Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.muted, width: 1.5),
                  color: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Title + optional notes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.task.title, style: AppTextStyles.itemTitle),
                  if (widget.task.notes != null &&
                      widget.task.notes!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(widget.task.notes!, style: AppTextStyles.itemMeta),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Created date
            Text(dateLabel, style: AppTextStyles.itemMeta),
          ],
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
  bool _addTaskHovered = false;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      widget.onSubmit(title);
    }
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
      return _AddTaskPrompt(
        isHovered: _addTaskHovered,
        onHoverChanged: (hovered) {
          setState(() => _addTaskHovered = hovered);
        },
        onTap: _expand,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Placeholder hollow circle matching task rows
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.muted.withValues(alpha: 0.4),
                width: 1.5,
              ),
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
                  hintText: 'Task name',
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
          // Send icon
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

class _AddTaskPrompt extends StatelessWidget {
  const _AddTaskPrompt({
    required this.isHovered,
    required this.onHoverChanged,
    required this.onTap,
  });

  final bool isHovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          color: isHovered ? AppColors.hoverBackground : Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(Icons.add, size: 16, color: AppColors.muted),
              const SizedBox(width: AppSpacing.sm),
              Text('Add task', style: AppTextStyles.bodyMuted),
            ],
          ),
        ),
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
        child: Text(
          "No tasks, you're all free :)",
          style: AppTextStyles.bodyMuted,
        ),
      ),
    );
  }
}

// ── Shimmer placeholder ──────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return SmoothListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 5,
      itemBuilder: (_, i) => const _ShimmerRow(),
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.divider,
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
            width: 36,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
