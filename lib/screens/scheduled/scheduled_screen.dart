import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/database_provider.dart';
import '../../providers/scheduled_tasks_provider.dart';
import '../../providers/selected_date_provider.dart';
import '../../theme/app_theme.dart';

class ScheduledScreen extends ConsumerWidget {
  const ScheduledScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final tasksAsync = ref.watch(scheduledTasksForDateProvider(selectedDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateHeader(date: selectedDate),
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
            data: (tasks) => _TaskList(tasks: tasks, selectedDate: selectedDate),
          ),
        ),
      ],
    );
  }
}

// ── Date header ──────────────────────────────────────────────────────────────

class _DateHeader extends ConsumerWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekday = _weekdays[date.weekday - 1];
    final month = _months[date.month - 1];
    final label = '$weekday, $month ${date.day}';

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.itemTitle.copyWith(
              fontWeight: FontWeight.w600,
            )),
          ),
          _ArrowButton(
            icon: Icons.chevron_left,
            onTap: () => ref.read(selectedDateProvider.notifier).state =
                date.subtract(const Duration(days: 1)),
          ),
          const SizedBox(width: 2),
          _ArrowButton(
            icon: Icons.chevron_right,
            onTap: () => ref.read(selectedDateProvider.notifier).state =
                date.add(const Duration(days: 1)),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatefulWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.hoverBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(widget.icon, size: 18, color: AppColors.muted),
        ),
      ),
    );
  }
}

// ── Task list ────────────────────────────────────────────────────────────────

class _TaskList extends ConsumerStatefulWidget {
  const _TaskList({required this.tasks, required this.selectedDate});

  final List<ScheduledTaskWithDate> tasks;
  final DateTime selectedDate;

  @override
  ConsumerState<_TaskList> createState() => _TaskListState();
}

class _TaskListState extends ConsumerState<_TaskList> {
  // Single parent-owned hover key — only one row highlighted at a time.
  int? _hoveredId;

  Future<void> _insert(String title, DateTime date) async {
    final db = ref.read(appDatabaseProvider);
    await db.scheduledTasksDao.insertScheduledTask(title, date);
  }

  Future<void> _complete(int id) async {
    final db = ref.read(appDatabaseProvider);
    await db.scheduledTasksDao.markComplete(id);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.tasks;
    final itemCount = tasks.isEmpty ? 2 : tasks.length + 1;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (tasks.isEmpty) {
          if (index == 0) return const _EmptyState();
          return _CaptureRow(
            initialDate: widget.selectedDate,
            onSubmit: (title, date) => _insert(title, date),
          );
        }

        if (index == tasks.length) {
          return _CaptureRow(
            initialDate: widget.selectedDate,
            onSubmit: (title, date) => _insert(title, date),
          );
        }

        final task = tasks[index];
        return _TaskRow(
          task: task,
          hovered: _hoveredId == task.item.id,
          onHoverChanged: (on) => setState(
            () => _hoveredId = on ? task.item.id : null,
          ),
          onComplete: () => _complete(task.item.id),
        );
      },
    );
  }
}

// ── Individual task row ──────────────────────────────────────────────────────

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.hovered,
    required this.onHoverChanged,
    required this.onComplete,
  });

  final ScheduledTaskWithDate task;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onComplete;

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.month}/${dt.day}/${dt.year.toString().substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final dateMeta = task.endDate != null ? _formatDate(task.endDate) : '';

    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: hovered ? AppColors.hoverBackground : AppColors.background,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onComplete,
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
                    Text(task.item.title, style: AppTextStyles.itemTitle),
                    if (task.item.notes != null &&
                        task.item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(task.item.notes!, style: AppTextStyles.itemMeta),
                    ],
                    if (dateMeta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 11,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 3),
                          Text(dateMeta, style: AppTextStyles.itemMeta),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Capture row ──────────────────────────────────────────────────────────────

class _CaptureRow extends StatefulWidget {
  const _CaptureRow({
    required this.initialDate,
    required this.onSubmit,
  });

  final DateTime initialDate;
  final void Function(String title, DateTime date) onSubmit;

  @override
  State<_CaptureRow> createState() => _CaptureRowState();
}

class _CaptureRowState extends State<_CaptureRow> {
  bool _expanded = false;
  bool _promptHovered = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late DateTime _pickedDate;

  @override
  void initState() {
    super.initState();
    _pickedDate = widget.initialDate;
  }

  @override
  void didUpdateWidget(_CaptureRow old) {
    super.didUpdateWidget(old);
    // Keep picker in sync if the parent date changes while collapsed.
    if (!_expanded) _pickedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() {
      _expanded = true;
      _pickedDate = widget.initialDate;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      widget.onSubmit(title, _pickedDate);
    }
    _controller.clear();
    setState(() => _expanded = false);
  }

  void _cancel() {
    _controller.clear();
    setState(() => _expanded = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.accent,
            onPrimary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _pickedDate = picked);
  }

  String _formatPickedDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year.toString().substring(2)}';
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
                Text('Add task', style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
              GestureDetector(
                onTap: _submit,
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  child: Icon(Icons.send, size: 16, color: AppColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Date picker chip
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatPickedDate(_pickedDate),
                    style: AppTextStyles.itemMeta,
                  ),
                ],
              ),
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
        child: Text(
          'Nothing scheduled for this day',
          style: AppTextStyles.bodyMuted,
        ),
      ),
    );
  }
}

// ── Shimmer placeholders ─────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
            width: 48,
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
