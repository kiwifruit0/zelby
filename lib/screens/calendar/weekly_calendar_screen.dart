import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/deadlines_provider.dart';
import '../../providers/events_provider.dart';
import '../../providers/scheduled_tasks_provider.dart';
import '../../providers/selected_date_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/smooth_scroll.dart';
import '../../widgets/task_detail_popup.dart';
import 'calendar_view_switcher.dart';

const _kDayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _kMonthsAbbrev = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const _kTaskColor = AppColors.accent;
const _kEventColor = Color(0xFF4CAF50);

Color _urgencyColor(DateTime? endDate) {
  if (endDate == null) return AppColors.muted;
  final days = endDate.difference(DateTime.now()).inDays;
  if (days < 3) return const Color(0xFFE53935);
  if (days <= 7) return const Color(0xFFFB8C00);
  return const Color(0xFF43A047);
}

// ── Domain object ─────────────────────────────────────────────────────────────

enum _ItemKind { scheduledTask, event, deadline }

class _CalItem {
  const _CalItem({
    required this.title,
    required this.kind,
    this.endDate,
    this.itemId,
  });

  final String title;
  final _ItemKind kind;
  final DateTime? endDate;
  final int? itemId;

  Color get color => switch (kind) {
    _ItemKind.scheduledTask => _kTaskColor,
    _ItemKind.event => _kEventColor,
    _ItemKind.deadline => _urgencyColor(endDate),
  };
}

// ── Week helpers ──────────────────────────────────────────────────────────────

DateTime _mondayOf(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  return d.subtract(Duration(days: d.weekday - 1));
}

List<DateTime> _weekDays(DateTime weekStart) =>
    List.generate(7, (i) => weekStart.add(Duration(days: i)));

String _weekLabel(DateTime weekStart) {
  final end = weekStart.add(const Duration(days: 6));
  final sm = _kMonthsAbbrev[weekStart.month - 1];
  final em = _kMonthsAbbrev[end.month - 1];
  if (weekStart.month == end.month) {
    return '$sm ${weekStart.day} – ${end.day}, ${end.year}';
  }
  return '$sm ${weekStart.day} – $em ${end.day}, ${end.year}';
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// ── Screen ────────────────────────────────────────────────────────────────────

class WeeklyCalendarScreen extends ConsumerStatefulWidget {
  const WeeklyCalendarScreen({super.key});

  @override
  ConsumerState<WeeklyCalendarScreen> createState() =>
      _WeeklyCalendarScreenState();
}

class _WeeklyCalendarScreenState extends ConsumerState<WeeklyCalendarScreen> {
  late DateTime _focusedWeekStart;
  // Parent-owned hover key — only one column header highlighted at a time.
  DateTime? _hoveredDay;

  @override
  void initState() {
    super.initState();
    _focusedWeekStart = _mondayOf(ref.read(selectedDateProvider));
  }

  DateTime get _weekEnd => _focusedWeekStart.add(const Duration(days: 7));

  void _prevWeek() => setState(
    () =>
        _focusedWeekStart = _focusedWeekStart.subtract(const Duration(days: 7)),
  );

  void _nextWeek() => setState(
    () => _focusedWeekStart = _focusedWeekStart.add(const Duration(days: 7)),
  );

  void _selectDay(DateTime day) {
    ref.read(selectedDateProvider.notifier).state = day;
    context.go('/calendar/daily');
  }

  Map<DateTime, List<_CalItem>> _buildItemsByDay(
    List<ScheduledTaskWithDate> tasks,
    List<EventWithDates> events,
    List<DeadlineWithDate> deadlines,
    List<DateTime> days,
  ) {
    final map = {for (final d in days) d: <_CalItem>[]};

    for (final t in tasks) {
      if (t.endDate == null) continue;
      final k = DateTime(t.endDate!.year, t.endDate!.month, t.endDate!.day);
      map[k]?.add(
        _CalItem(
          title: t.item.title,
          kind: _ItemKind.scheduledTask,
          endDate: t.endDate,
          itemId: t.item.id,
        ),
      );
    }

    for (final e in events) {
      if (e.startDate == null || e.endDate == null) continue;
      final eStart = DateTime(
        e.startDate!.year,
        e.startDate!.month,
        e.startDate!.day,
      );
      final eEnd = DateTime(e.endDate!.year, e.endDate!.month, e.endDate!.day);
      for (final d in days) {
        if (!d.isBefore(eStart) && !d.isAfter(eEnd)) {
          map[d]!.add(
            _CalItem(
              title: e.item.title,
              kind: _ItemKind.event,
              endDate: e.endDate,
              itemId: e.item.id,
            ),
          );
        }
      }
    }

    for (final d in deadlines) {
      if (d.endDate == null) continue;
      final k = DateTime(d.endDate!.year, d.endDate!.month, d.endDate!.day);
      map[k]?.add(
        _CalItem(
          title: d.item.title,
          kind: _ItemKind.deadline,
          endDate: d.endDate,
          itemId: d.item.id,
        ),
      );
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDateProvider);
    final days = _weekDays(_focusedWeekStart);

    final tasksAsync = ref.watch(
      scheduledTasksForDateRangeProvider(_focusedWeekStart, _weekEnd),
    );
    final eventsAsync = ref.watch(
      eventsForDateRangeProvider(_focusedWeekStart, _weekEnd),
    );
    final deadlinesAsync = ref.watch(activeDeadlinesProvider);

    final itemsByDay = _buildItemsByDay(
      tasksAsync.maybeWhen(data: (v) => v, orElse: () => const []),
      eventsAsync.maybeWhen(data: (v) => v, orElse: () => const []),
      deadlinesAsync.maybeWhen(data: (v) => v, orElse: () => const []),
      days,
    );

    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WeekNavBar(
          label: _weekLabel(_focusedWeekStart),
          onPrev: _prevWeek,
          onNext: _nextWeek,
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.divider),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < 7; i++) ...[
                if (i > 0) Container(width: 1, color: AppColors.divider),
                Expanded(
                  child: _DayColumn(
                    day: days[i],
                    isToday: _isSameDay(days[i], today),
                    isSelected: _isSameDay(days[i], selectedDay),
                    isHovered:
                        _hoveredDay != null &&
                        _isSameDay(_hoveredDay!, days[i]),
                    onHoverChanged: (on) =>
                        setState(() => _hoveredDay = on ? days[i] : null),
                    onTap: () => _selectDay(days[i]),
                    items: itemsByDay[days[i]] ?? const [],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Week navigation bar ───────────────────────────────────────────────────────

class _WeekNavBar extends StatelessWidget {
  const _WeekNavBar({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
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
          _ArrowButton(icon: Icons.chevron_left, onTap: onPrev),
          const SizedBox(width: 2),
          _ArrowButton(icon: Icons.chevron_right, onTap: onNext),
          const SizedBox(width: AppSpacing.sm),
          const CalendarViewSwitcher(currentView: CalendarView.weekly),
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

// ── Day column ────────────────────────────────────────────────────────────────

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isHovered,
    required this.onHoverChanged,
    required this.onTap,
    required this.items,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool isHovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;
  final List<_CalItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DayHeader(
          day: day,
          isToday: isToday,
          isSelected: isSelected,
          isHovered: isHovered,
          onHoverChanged: onHoverChanged,
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.divider),
        Expanded(
          child: items.isEmpty
              ? const SizedBox.shrink()
              : SmoothSingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: items
                        .map((item) => _ItemChip(item: item))
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Day header ────────────────────────────────────────────────────────────────

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isHovered,
    required this.onHoverChanged,
    required this.onTap,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool isHovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = isHovered ? AppColors.hoverBackground : Colors.transparent;

    final Color dateNumBg = isToday
        ? AppColors.accent
        : isSelected
        ? AppColors.accent.withValues(alpha: 0.25)
        : Colors.transparent;

    final Color labelColor = isToday ? AppColors.primary : AppColors.muted;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          color: bg,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _kDayNames[day.weekday - 1],
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.3,
                  color: labelColor,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dateNumBg,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1,
                    color: AppColors.primary,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Item chip ─────────────────────────────────────────────────────────────────

class _ItemChip extends StatefulWidget {
  const _ItemChip({required this.item});

  final _CalItem item;

  @override
  State<_ItemChip> createState() => _ItemChipState();
}

class _ItemChipState extends State<_ItemChip> {
  bool _hovered = false;

  Future<void> _openTaskDetail(BuildContext context) async {
    if (widget.item.itemId == null) return;
    await showTaskDetailDialog(
      context,
      TaskDetailParams(taskId: widget.item.itemId!, taskIds: [widget.item.itemId!]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.item.color;
    final canOpen = widget.item.kind == _ItemKind.scheduledTask && widget.item.itemId != null;

    return MouseRegion(
      cursor: canOpen ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: canOpen ? () => _openTaskDetail(context) : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 2.5)),
            color: _hovered
                ? color.withValues(alpha: 0.15)
                : color.withValues(alpha: 0.07),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(3),
              bottomRight: Radius.circular(3),
            ),
          ),
          child: Text(
            widget.item.title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
