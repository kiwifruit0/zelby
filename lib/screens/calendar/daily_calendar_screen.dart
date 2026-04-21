import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/database_provider.dart';
import '../../providers/inbox_provider.dart';
import '../../providers/scheduled_tasks_provider.dart';
import '../../providers/selected_date_provider.dart';
import '../../theme/app_theme.dart';
import 'calendar_view_switcher.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kFirstHour = 0;
const _kLastHour = 23; // slots 0–23 represent 0:00–23:00
const _kSlotHeight = 60.0;
const _kTimeAxisWidth = 52.0;

const _kWeekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _kMonths = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

// ── Helpers ───────────────────────────────────────────────────────────────────

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _formatHour(int h) {
  if (h == 0) return '12 AM';
  if (h < 12) return '$h AM';
  if (h == 12) return '12 PM';
  return '${h - 12} PM';
}

// ── Drag data ─────────────────────────────────────────────────────────────────

class _TaskDragData {
  const _TaskDragData({
    required this.taskId,
    required this.title,
    required this.source,
  });

  final int taskId;
  final String title;
  final _DragSource source;
}

enum _DragSource { scheduled, inbox }

// ── Screen ────────────────────────────────────────────────────────────────────

class DailyCalendarScreen extends ConsumerWidget {
  const DailyCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateBar(),
        Divider(height: 1, thickness: 1, color: AppColors.divider),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: _TimelinePanel()),
              _VerticalRule(),
              Expanded(flex: 1, child: _SidebarPanel()),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerticalRule extends StatelessWidget {
  const _VerticalRule();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, color: AppColors.divider);
}

// ── Date bar ──────────────────────────────────────────────────────────────────

class _DateBar extends ConsumerWidget {
  const _DateBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final label =
        '${_kWeekdays[date.weekday - 1]}, ${_kMonths[date.month - 1]} ${date.day}';

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.itemTitle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _ArrowButton(
            icon: Icons.chevron_left,
            onTap: () => ref.read(selectedDateProvider.notifier).state = date
                .subtract(const Duration(days: 1)),
          ),
          const SizedBox(width: 2),
          _ArrowButton(
            icon: Icons.chevron_right,
            onTap: () => ref.read(selectedDateProvider.notifier).state = date
                .add(const Duration(days: 1)),
          ),
          const SizedBox(width: AppSpacing.sm),
          const CalendarViewSwitcher(currentView: CalendarView.daily),
        ],
      ),
    );
  }
}

// ── Timeline panel ────────────────────────────────────────────────────────────

class _TimelinePanel extends ConsumerStatefulWidget {
  const _TimelinePanel();

  @override
  ConsumerState<_TimelinePanel> createState() => _TimelinePanelState();
}

class _TimelinePanelState extends ConsumerState<_TimelinePanel> {
  late final ScrollController _scrollController;
  // Parent-owned hover key for the "Unscheduled" section rows.
  int? _hoveredUntimedId;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToAnchor());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll to ~1 hour before now if today, otherwise 8 am.
  void _scrollToAnchor() {
    if (!_scrollController.hasClients) return;
    final now = DateTime.now();
    final sel = ref.read(selectedDateProvider);
    final target = _isSameDay(now, sel)
        ? (now.hour - 1).clamp(_kFirstHour, _kLastHour)
        : 8;
    final offset = ((target - _kFirstHour) * _kSlotHeight).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.jumpTo(offset);
  }

  Future<void> _onDrop(_TaskDragData data, int hour) async {
    final sel = ref.read(selectedDateProvider);
    final newDate = DateTime(sel.year, sel.month, sel.day, hour);
    final db = ref.read(appDatabaseProvider);

    if (data.source == _DragSource.inbox) {
      await db.scheduledTasksDao.scheduleInboxTask(data.taskId, newDate);
    } else {
      await db.scheduledTasksDao.updateTask(data.taskId, date: newDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(selectedDateProvider);

    // Re-anchor scroll when the selected date changes.
    ref.listen<DateTime>(selectedDateProvider, (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToAnchor());
    });

    final tasks = ref
        .watch(scheduledTasksForDateProvider(date))
        .maybeWhen(data: (t) => t, orElse: () => const []);

    // Split tasks: untimed (midnight ≡ no clock time) vs timed.
    final untimed = <ScheduledTaskWithDate>[];
    final byHour = <int, List<ScheduledTaskWithDate>>{};

    for (final t in tasks) {
      final end = t.endDate;
      if (end == null || (end.hour == 0 && end.minute == 0)) {
        untimed.add(t);
      } else {
        (byHour[end.hour] ??= []).add(t);
      }
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (untimed.isNotEmpty)
            _UnscheduledSection(
              tasks: untimed,
              hoveredId: _hoveredUntimedId,
              onHoverChanged: (id, on) =>
                  setState(() => _hoveredUntimedId = on ? id : null),
            ),
          for (int h = _kFirstHour; h <= _kLastHour; h++)
            _TimeSlot(
              hour: h,
              tasks: byHour[h] ?? const [],
              onAccept: (data) => _onDrop(data, h),
            ),
        ],
      ),
    );
  }
}

// ── Unscheduled section ───────────────────────────────────────────────────────

class _UnscheduledSection extends StatelessWidget {
  const _UnscheduledSection({
    required this.tasks,
    required this.hoveredId,
    required this.onHoverChanged,
  });

  final List<ScheduledTaskWithDate> tasks;
  final int? hoveredId;
  final void Function(int id, bool on) onHoverChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sidebarBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              4,
            ),
            child: Text('UNSCHEDULED', style: AppTextStyles.sectionHeader),
          ),
          for (final task in tasks)
            _UntimedTaskRow(
              task: task,
              hovered: hoveredId == task.item.id,
              onHoverChanged: (on) => onHoverChanged(task.item.id, on),
            ),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
        ],
      ),
    );
  }
}

// ── Untimed task row (draggable) ──────────────────────────────────────────────

class _UntimedTaskRow extends StatelessWidget {
  const _UntimedTaskRow({
    required this.task,
    required this.hovered,
    required this.onHoverChanged,
  });

  final ScheduledTaskWithDate task;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;

  @override
  Widget build(BuildContext context) {
    return Draggable<_TaskDragData>(
      data: _TaskDragData(
        taskId: task.item.id,
        title: task.item.title,
        source: _DragSource.scheduled,
      ),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _DragFeedback(title: task.item.title),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _UntimedTaskRowContent(task: task, hovered: false),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        onEnter: (_) => onHoverChanged(true),
        onExit: (_) => onHoverChanged(false),
        child: _UntimedTaskRowContent(task: task, hovered: hovered),
      ),
    );
  }
}

class _UntimedTaskRowContent extends StatelessWidget {
  const _UntimedTaskRowContent({required this.task, required this.hovered});

  final ScheduledTaskWithDate task;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: hovered ? AppColors.hoverBackground : Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const SizedBox(width: _kTimeAxisWidth, child: SizedBox.shrink()),
          const Icon(Icons.drag_indicator, size: 14, color: AppColors.muted),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(task.item.title, style: AppTextStyles.itemTitle),
          ),
        ],
      ),
    );
  }
}

// ── Drag feedback chip ────────────────────────────────────────────────────────

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primary,
            decoration: TextDecoration.none,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// ── Time slot (DragTarget) ────────────────────────────────────────────────────

class _TimeSlot extends StatelessWidget {
  const _TimeSlot({
    required this.hour,
    required this.tasks,
    required this.onAccept,
  });

  final int hour;
  final List<ScheduledTaskWithDate> tasks;
  final ValueChanged<_TaskDragData> onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<_TaskDragData>(
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidates, _) {
        final isTarget = candidates.isNotEmpty;
        return Container(
          constraints: const BoxConstraints(minHeight: _kSlotHeight),
          decoration: BoxDecoration(
            color: isTarget
                ? AppColors.accent.withValues(alpha: 0.08)
                : Colors.transparent,
            border: const Border(
              top: BorderSide(color: AppColors.divider, width: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hour label column.
              SizedBox(
                width: _kTimeAxisWidth,
                height: _kSlotHeight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, right: AppSpacing.sm),
                  child: Text(
                    _formatHour(hour),
                    style: AppTextStyles.itemMeta,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              // Task block area.
              Expanded(
                child: tasks.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: tasks
                              .map((t) => _ScheduledTaskBlock(task: t))
                              .toList(),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Scheduled task block (inside a time slot) ─────────────────────────────────

class _ScheduledTaskBlock extends StatelessWidget {
  const _ScheduledTaskBlock({required this.task});

  final ScheduledTaskWithDate task;

  @override
  Widget build(BuildContext context) {
    return Draggable<_TaskDragData>(
      data: _TaskDragData(
        taskId: task.item.id,
        title: task.item.title,
        source: _DragSource.scheduled,
      ),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _DragFeedback(title: task.item.title),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _ScheduledTaskBlockContent(task: task),
      ),
      child: _ScheduledTaskBlockContent(task: task),
    );
  }
}

class _ScheduledTaskBlockContent extends StatelessWidget {
  const _ScheduledTaskBlockContent({required this.task});

  final ScheduledTaskWithDate task;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        border: const Border(
          left: BorderSide(color: AppColors.accent, width: 3),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(3),
          bottomRight: Radius.circular(3),
        ),
      ),
      child: Text(
        task.item.title,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          height: 1.3,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ── Sidebar panel (inbox tasks) ───────────────────────────────────────────────

class _SidebarPanel extends ConsumerStatefulWidget {
  const _SidebarPanel();

  @override
  ConsumerState<_SidebarPanel> createState() => _SidebarPanelState();
}

class _SidebarPanelState extends ConsumerState<_SidebarPanel> {
  // Parent-owned hover key for inbox rows.
  int? _hoveredId;

  Future<void> _complete(int id) async =>
      ref.read(appDatabaseProvider).inboxDao.markComplete(id);

  Future<void> _insert(String title) async =>
      ref.read(appDatabaseProvider).inboxDao.insertTask(title);

  @override
  Widget build(BuildContext context) {
    final tasks = ref
        .watch(inboxTasksProvider)
        .maybeWhen(data: (t) => t, orElse: () => const <Item>[]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Text('INBOX', style: AppTextStyles.sectionHeader),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: tasks.length + 1,
            itemBuilder: (context, index) {
              if (index == tasks.length) {
                return _CaptureBar(onSubmit: _insert);
              }
              final task = tasks[index];
              return _InboxRow(
                task: task,
                hovered: _hoveredId == task.id,
                onHoverChanged: (on) =>
                    setState(() => _hoveredId = on ? task.id : null),
                onComplete: () => _complete(task.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Inbox task row ────────────────────────────────────────────────────────────

class _InboxRow extends StatelessWidget {
  const _InboxRow({
    required this.task,
    required this.hovered,
    required this.onHoverChanged,
    required this.onComplete,
  });

  final Item task;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Draggable<_TaskDragData>(
      data: _TaskDragData(
        taskId: task.id,
        title: task.title,
        source: _DragSource.inbox,
      ),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _DragFeedback(title: task.title),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _InboxRowContent(
          task: task,
          hovered: false,
          onComplete: onComplete,
        ),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        onEnter: (_) => onHoverChanged(true),
        onExit: (_) => onHoverChanged(false),
        child: _InboxRowContent(
          task: task,
          hovered: hovered,
          onComplete: onComplete,
        ),
      ),
    );
  }
}

class _InboxRowContent extends StatelessWidget {
  const _InboxRowContent({
    required this.task,
    required this.hovered,
    required this.onComplete,
  });

  final Item task;
  final bool hovered;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.muted, width: 1.5),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(task.title, style: AppTextStyles.itemTitle)),
          ],
        ),
      ),
    );
  }
}

// ── Inline capture bar ────────────────────────────────────────────────────────

class _CaptureBar extends StatefulWidget {
  const _CaptureBar({required this.onSubmit});

  final void Function(String title) onSubmit;

  @override
  State<_CaptureBar> createState() => _CaptureBarState();
}

class _CaptureBarState extends State<_CaptureBar> {
  bool _expanded = false;
  bool _promptHovered = false;
  final _controller = TextEditingController();
  final _fieldFocusNode = FocusNode();
  final _keyListenerFocusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _fieldFocusNode.dispose();
    _keyListenerFocusNode.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() => _expanded = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _fieldFocusNode.requestFocus(),
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
                const Icon(Icons.add, size: 14, color: AppColors.muted),
                const SizedBox(width: AppSpacing.xs),
                Text('Add task', style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
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
              focusNode: _keyListenerFocusNode,
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  _cancel();
                }
              },
              child: TextField(
                controller: _controller,
                focusNode: _fieldFocusNode,
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
              child: Icon(Icons.send, size: 14, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared arrow button ───────────────────────────────────────────────────────

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
