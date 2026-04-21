import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../providers/deadlines_provider.dart';
import '../../providers/events_provider.dart';
import '../../providers/scheduled_tasks_provider.dart';
import '../../providers/selected_date_provider.dart';
import '../../theme/app_theme.dart';
import 'calendar_view_switcher.dart';

// Per-type dot colours shown in the calendar marker row.
const _kTaskColor = AppColors.accent;
const _kEventColor = Color(0xFF4CAF50);
const _kDeadlineColor = Color(0xFFE53935);

class MonthlyCalendarScreen extends ConsumerStatefulWidget {
  const MonthlyCalendarScreen({super.key});

  @override
  ConsumerState<MonthlyCalendarScreen> createState() =>
      _MonthlyCalendarScreenState();
}

class _MonthlyCalendarScreenState extends ConsumerState<MonthlyCalendarScreen> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  // Exclusive upper bound so the range query uses [start, end).
  DateTime get _rangeStart => DateTime(_focusedDay.year, _focusedDay.month, 1);
  DateTime get _rangeEnd =>
      DateTime(_focusedDay.year, _focusedDay.month + 1, 1);

  Map<DateTime, Set<String>> _buildMarkers(
    List<EventWithDates> events,
    List<ScheduledTaskWithDate> tasks,
    List<DeadlineWithDate> deadlines,
  ) {
    final map = <DateTime, Set<String>>{};

    void add(DateTime dt, String type) =>
        (map[DateTime(dt.year, dt.month, dt.day)] ??= {}).add(type);

    // Events span multiple days — mark every day in range.
    for (final e in events) {
      if (e.startDate == null || e.endDate == null) continue;
      var d = DateTime(e.startDate!.year, e.startDate!.month, e.startDate!.day);
      final last = DateTime(e.endDate!.year, e.endDate!.month, e.endDate!.day);
      while (!d.isAfter(last)) {
        add(d, 'event');
        d = d.add(const Duration(days: 1));
      }
    }

    for (final t in tasks) {
      if (t.endDate != null) add(t.endDate!, 'scheduled_task');
    }

    // Active deadlines span all months — filter to the focused month.
    final y = _focusedDay.year;
    final m = _focusedDay.month;
    for (final d in deadlines) {
      final end = d.endDate;
      if (end != null && end.year == y && end.month == m) {
        add(end, 'deadline');
      }
    }

    return map;
  }

  void _prevMonth() => setState(
    () => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1),
  );

  void _nextMonth() => setState(
    () => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1),
  );

  void _onDaySelected(DateTime selected, DateTime focused) {
    ref.read(selectedDateProvider.notifier).state = selected;
    setState(() => _focusedDay = focused);
    context.go('/calendar/daily');
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDateProvider);

    final eventsAsync = ref.watch(
      eventsForDateRangeProvider(_rangeStart, _rangeEnd),
    );
    final tasksAsync = ref.watch(
      scheduledTasksForDateRangeProvider(_rangeStart, _rangeEnd),
    );
    final deadlinesAsync = ref.watch(activeDeadlinesProvider);

    final markersByDay = _buildMarkers(
      eventsAsync.maybeWhen(data: (v) => v, orElse: () => const []),
      tasksAsync.maybeWhen(data: (v) => v, orElse: () => const []),
      deadlinesAsync.maybeWhen(data: (v) => v, orElse: () => const []),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MonthHeader(
          focusedDay: _focusedDay,
          onPrev: _prevMonth,
          onNext: _nextMonth,
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.divider),
        Expanded(
          child: TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, selectedDay),
            onDaySelected: _onDaySelected,
            onPageChanged: (focused) => setState(() => _focusedDay = focused),
            headerVisible: false,
            rowHeight: 52,
            daysOfWeekHeight: 28,
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontSize: 11,
                color: AppColors.muted,
                letterSpacing: 0.3,
              ),
              weekendStyle: TextStyle(
                fontSize: 11,
                color: AppColors.muted,
                letterSpacing: 0.3,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              cellMargin: const EdgeInsets.all(4),
              // Strip all default cell decorations.
              defaultDecoration: const BoxDecoration(),
              weekendDecoration: const BoxDecoration(),
              outsideDecoration: const BoxDecoration(),
              disabledDecoration: const BoxDecoration(),
              holidayDecoration: const BoxDecoration(),
              // Today: accent-coloured border only.
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 1.5),
              ),
              // Selected day: filled accent circle.
              selectedDecoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent,
              ),
              // Text styles.
              defaultTextStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
              ),
              weekendTextStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.muted,
              ),
              todayTextStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              selectedTextStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
              ),
              outsideTextStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.divider,
              ),
              disabledTextStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.divider,
              ),
              // Suppress default markers — we use a custom builder.
              markersMaxCount: 0,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, _) {
                final key = DateTime(day.year, day.month, day.day);
                final types = markersByDay[key];
                if (types == null || types.isEmpty) return null;
                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (types.contains('scheduled_task'))
                        _Dot(color: _kTaskColor),
                      if (types.contains('event')) _Dot(color: _kEventColor),
                      if (types.contains('deadline'))
                        _Dot(color: _kDeadlineColor),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── Month header ──────────────────────────────────────────────────────────────

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

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.focusedDay,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime focusedDay;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final label = '${_kMonths[focusedDay.month - 1]} ${focusedDay.year}';

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
          const CalendarViewSwitcher(currentView: CalendarView.monthly),
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

// ── Marker dot ────────────────────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
