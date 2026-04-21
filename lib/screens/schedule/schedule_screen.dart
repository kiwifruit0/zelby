import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/database_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../theme/app_theme.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  static const _daysAhead = 30;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _dayKeys = {};

  late List<DateTime> _dates;
  int _highlightedIndex = 0;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dates = List.generate(
      _daysAhead,
      (i) => DateTime(today.year, today.month, today.day + i),
    );

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final itemHeight = 60.0;
    final index = (offset / itemHeight).floor();
    if (index >= 0 && index < _dates.length && index != _highlightedIndex) {
      setState(() => _highlightedIndex = index);
    }
  }

  void _scrollToDate(int index) {
    if (!_scrollController.hasClients) return;
    final key = _dayKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final itemHeight = 60.0;
      _scrollController.animateTo(
        index * itemHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    setState(() => _highlightedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: _daysAhead + 1));
    final scheduleAsync = ref.watch(scheduleForDateRangeProvider(start, end));

    return Column(
      children: [
        _DatePickerBar(
          dates: _dates,
          highlightedIndex: _highlightedIndex,
          onDateTap: _scrollToDate,
        ),
        Expanded(
          child: scheduleAsync.when(
            loading: () => const _ShimmerList(),
            error: (e, _) => Center(
              child: Text(
                'Something went wrong: $e',
                style: AppTextStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
            ),
            data: (days) => _ScheduleList(
              days: days,
              dates: _dates,
              scrollController: _scrollController,
              onDayKeyCreated: (index, key) => _dayKeys[index] = key,
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePickerBar extends StatelessWidget {
  const _DatePickerBar({
    required this.dates,
    required this.highlightedIndex,
    required this.onDateTap,
  });

  final List<DateTime> dates;
  final int highlightedIndex;
  final void Function(int index) onDateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isHighlighted = index == highlightedIndex;
          final isToday = _isToday(date);

          return _DateChip(
            date: date,
            isHighlighted: isHighlighted,
            isToday: isToday,
            onTap: () => onDateTap(index),
          );
        },
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _DateChip extends StatefulWidget {
  const _DateChip({
    required this.date,
    required this.isHighlighted,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool isHighlighted;
  final bool isToday;
  final VoidCallback onTap;

  @override
  State<_DateChip> createState() => _DateChipState();
}

class _DateChipState extends State<_DateChip> {
  bool _hovered = false;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdays[widget.date.weekday - 1];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          width: 48,
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isHighlighted
                ? AppColors.accent.withValues(alpha: 0.15)
                : (_hovered ? AppColors.hoverBackground : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekday,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isHighlighted ? AppColors.accent : AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.date.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isHighlighted
                      ? AppColors.accent
                      : (widget.isToday ? AppColors.accent : AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleList extends StatelessWidget {
  const _ScheduleList({
    required this.days,
    required this.dates,
    required this.scrollController,
    required this.onDayKeyCreated,
  });

  final List<ScheduleDay> days;
  final List<DateTime> dates;
  final ScrollController scrollController;
  final void Function(int index, GlobalKey key) onDayKeyCreated;

  @override
  Widget build(BuildContext context) {
    final items = <_DaySection>[];

    for (int i = 0; i < dates.length; i++) {
      final date = dates[i];
      final scheduleDay = days.where((d) =>
          d.date.year == date.year &&
          d.date.month == date.month &&
          d.date.day == date.day).firstOrNull;

      items.add(_DaySection(
        key: GlobalKey(),
        date: date,
        items: scheduleDay?.items ?? [],
      ));
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final section = items[index];
        return _DaySection(
          key: section.key,
          date: section.date,
          items: section.items,
        );
      },
    );
  }
}

class _DaySection extends ConsumerWidget {
  const _DaySection({
    super.key,
    required this.date,
    required this.items,
  });

  final DateTime date;
  final List<ScheduleItem> items;

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
    final isToday = _isToday(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                '$weekday, $month ${date.day}',
                style: AppTextStyles.itemTitle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isToday ? AppColors.accent : AppColors.primary,
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: Text(
              'Nothing scheduled',
              style: AppTextStyles.bodyMuted.copyWith(fontSize: 13),
            ),
          )
        else
          ...items.map((item) => _ScheduleItemRow(item: item)),
      ],
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}

class _ScheduleItemRow extends StatelessWidget {
  const _ScheduleItemRow({required this.item});

  final ScheduleItem item;

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final hour = dt.hour;
    final minute = dt.minute;
    final period = hour < 12 ? 'AM' : 'PM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    if (minute == 0) return '$h12 $period';
    final mm = minute.toString().padLeft(2, '0');
    return '$h12:$mm $period';
  }

  String _formatTimeRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '';
    if (end == null) return _formatTime(start);
    if (start == null) return _formatTime(end);
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  Color _deadlineColor() {
    final end = item.endDate;
    if (end == null) return AppColors.muted;

    final now = DateTime.now();
    final diff = end.difference(now);

    if (diff.isNegative) return AppColors.muted;
    if (diff.inHours < 24) return const Color(0xFFE84C3D);
    if (diff.inHours < 72) return const Color(0xFFF5A623);
    return AppColors.muted;
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = item.isCompleted;
    final isEvent = item.itemType == ScheduleItemType.event;
    final isDeadline = item.itemType == ScheduleItemType.deadline;

    String timeLabel;
    Color timeColor = AppColors.muted;

    if (isEvent) {
      timeLabel = _formatTimeRange(item.startDate, item.endDate);
      timeColor = const Color(0xFF1E8E3E);
    } else if (isDeadline) {
      timeLabel = _formatTime(item.endDate);
      timeColor = isCompleted ? AppColors.muted : _deadlineColor();
    } else {
      timeLabel = _formatTime(item.endDate);
    }

    return _ItemRow(
      item: item,
      isCompleted: isCompleted,
      isEvent: isEvent,
      timeLabel: timeLabel,
      timeColor: timeColor,
    );
  }
}

class _ItemRow extends ConsumerStatefulWidget {
  const _ItemRow({
    required this.item,
    required this.isCompleted,
    required this.isEvent,
    required this.timeLabel,
    required this.timeColor,
  });

  final ScheduleItem item;
  final bool isCompleted;
  final bool isEvent;
  final String timeLabel;
  final Color timeColor;

  @override
  ConsumerState<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends ConsumerState<_ItemRow> {
  bool _hovered = false;

  Future<void> _toggleComplete() async {
    final db = ref.read(appDatabaseProvider);
    final itemType = widget.item.itemType;

    if (itemType == ScheduleItemType.scheduledTask) {
      await db.scheduledTasksDao.markComplete(widget.item.item.id);
    } else if (itemType == ScheduleItemType.deadline) {
      if (widget.item.isCompleted) {
        await db.deadlinesDao.softDelete(widget.item.item.id);
      } else {
        await db.deadlinesDao.markComplete(widget.item.item.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: _hovered ? AppColors.hoverBackground : Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeading(),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.item.title,
                      style: widget.isCompleted
                          ? AppTextStyles.itemTitle.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.muted,
                            )
                          : AppTextStyles.itemTitle,
                    ),
                    if (widget.item.item.notes != null &&
                        widget.item.item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.item.item.notes!,
                        style: AppTextStyles.itemMeta.copyWith(
                          decoration: widget.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.timeLabel.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    widget.timeLabel,
                    style: AppTextStyles.itemMeta.copyWith(color: widget.timeColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading() {
    if (widget.isEvent) {
      return Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.muted, width: 1.5),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.isEvent ? null : _toggleComplete,
      child: Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.isCompleted ? AppColors.accent : AppColors.muted,
            width: 1.5,
          ),
          color: widget.isCompleted ? AppColors.accent : Colors.transparent,
        ),
        child: widget.isCompleted
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 10,
      itemBuilder: (context, index) => const _ShimmerRow(),
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
            width: 20,
            height: 20,
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