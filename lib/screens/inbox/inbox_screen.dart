import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/daos/inbox_dao.dart';
import '../../providers/database_provider.dart';
import '../../providers/inbox_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/smooth_scroll.dart';
import '../../widgets/task_detail_popup.dart';
import '../../widgets/task_popup.dart';

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
          return _CaptureRow(onTap: () => _addTask(context, ref));
        }

        if (index == tasks.length) {
          return _CaptureRow(onTap: () => _addTask(context, ref));
        }

        return _TaskRow(
          task: tasks[index],
          onComplete: () => _complete(ref, tasks[index].id),
          onTap: () => _openTaskDetail(context, tasks, index),
        );
      },
    );
  }

  Future<void> _complete(WidgetRef ref, int id) async {
    final db = ref.read(appDatabaseProvider);
    await InboxDao(db).markComplete(id);
  }

  Future<void> _addTask(BuildContext context, WidgetRef ref) async {
    final draft = await showAddTaskDialog(
      context,
      initialDate: DateTime.now(),
    );
    if (draft == null) return;
    await persistTaskDraft(ref.read(appDatabaseProvider), draft);
  }

  Future<void> _openTaskDetail(BuildContext context, List<Item> tasks, int index) async {
    final taskIds = tasks.map((t) => t.id).toList();
    await showTaskDetailDialog(
      context,
      TaskDetailParams(taskId: tasks[index].id, taskIds: taskIds),
    );
  }
}

// ── Individual task row ──────────────────────────────────────────────────────

class _TaskRow extends StatefulWidget {
  const _TaskRow({
    required this.task,
    required this.onComplete,
    required this.onTap,
  });

  final Item task;
  final VoidCallback onComplete;
  final VoidCallback onTap;

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
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          color: _hovered ? AppColors.hoverBackground : AppColors.background,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(dateLabel, style: AppTextStyles.itemMeta),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Capture row ──────────────────────────────────────────────────────────────

class _CaptureRow extends StatefulWidget {
  const _CaptureRow({required this.onTap});

  final Future<void> Function() onTap;

  @override
  State<_CaptureRow> createState() => _CaptureRowState();
}

class _CaptureRowState extends State<_CaptureRow> {
  @override
  Widget build(BuildContext context) {
    return TaskAddPromptButton(
      onTap: widget.onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
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
