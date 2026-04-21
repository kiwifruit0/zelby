import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/database_provider.dart';
import '../../providers/deadlines_provider.dart';
import '../../providers/events_provider.dart';
import '../../theme/app_theme.dart';

enum _Tab { events, deadlines }

class EventsDeadlinesScreen extends ConsumerStatefulWidget {
  const EventsDeadlinesScreen({super.key});

  @override
  ConsumerState<EventsDeadlinesScreen> createState() =>
      _EventsDeadlinesScreenState();
}

class _EventsDeadlinesScreenState extends ConsumerState<EventsDeadlinesScreen> {
  _Tab _selectedTab = _Tab.events;

  @override
  void initState() {
    super.initState();
    final db = ref.read(appDatabaseProvider);
    db.eventsDao.autoCompleteExpiredEvents();
    db.deadlinesDao.autoCompleteExpiredDeadlines();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text('Events & Deadlines', style: AppTextStyles.pageTitle),
        ),
        _TabBar(
          selectedTab: _selectedTab,
          onTabChanged: (tab) => setState(() => _selectedTab = tab),
        ),
        Expanded(
          child: _selectedTab == _Tab.events
              ? const _EventsContent()
              : const _DeadlinesContent(),
        ),
      ],
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.selectedTab,
    required this.onTabChanged,
  });

  final _Tab selectedTab;
  final void Function(_Tab) onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Events',
            isActive: selectedTab == _Tab.events,
            onTap: () => onTabChanged(_Tab.events),
          ),
          const SizedBox(width: AppSpacing.xs),
          _TabButton(
            label: 'Deadlines',
            isActive: selectedTab == _Tab.deadlines,
            onTap: () => onTabChanged(_Tab.deadlines),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatefulWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.accent.withValues(alpha: 0.12)
                : _hovered
                    ? AppColors.hoverBackground
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.sidebarItem.copyWith(
              color: widget.isActive ? AppColors.accent : AppColors.primary,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _EventsContent extends ConsumerStatefulWidget {
  const _EventsContent();

  @override
  ConsumerState<_EventsContent> createState() => _EventsContentState();
}

class _EventsContentState extends ConsumerState<_EventsContent> {
  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return eventsAsync.when(
      loading: () => const _ShimmerList(),
      error: (e, _) => Center(
        child: Text(
          'Something went wrong: $e',
          style: AppTextStyles.bodyMuted,
          textAlign: TextAlign.center,
        ),
      ),
      data: (events) {
        final sorted = [...events]
          ..sort((a, b) {
            final aStart = a.startDate ?? DateTime(9999);
            final bStart = b.startDate ?? DateTime(9999);
            return aStart.compareTo(bStart);
          });
        return _EventList(events: sorted);
      },
    );
  }
}

class _EventList extends ConsumerStatefulWidget {
  const _EventList({required this.events});

  final List<EventWithDates> events;

  @override
  ConsumerState<_EventList> createState() => _EventListState();
}

class _EventListState extends ConsumerState<_EventList> {
  int? _hoveredId;

  Future<void> _insert(String title, DateTime start, DateTime end) async {
    await ref.read(appDatabaseProvider).eventsDao.insertEvent(title, start, end);
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.events;
    final itemCount = events.isEmpty ? 2 : events.length + 1;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (events.isEmpty) {
          if (index == 0) return const _EmptyState(message: 'No upcoming events');
          return _EventCaptureRow(onSubmit: _insert);
        }

        if (index == events.length) {
          return _EventCaptureRow(onSubmit: _insert);
        }

        final event = events[index];
        return _EventRow(
          event: event,
          hovered: _hoveredId == event.item.id,
          onHoverChanged: (on) =>
              setState(() => _hoveredId = on ? event.item.id : null),
        );
      },
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.event,
    required this.hovered,
    required this.onHoverChanged,
  });

  final EventWithDates event;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;

  bool _isHappening() {
    final now = DateTime.now();
    final s = event.startDate;
    final e = event.endDate;
    if (s == null || e == null) return false;
    return !now.isBefore(s) && !now.isAfter(e);
  }

  String _formatDate(DateTime dt) =>
      '${dt.month}/${dt.day}/${dt.year.toString().substring(2)}';

  @override
  Widget build(BuildContext context) {
    final happening = _isHappening();
    final startLabel =
        event.startDate != null ? _formatDate(event.startDate!) : '?';
    final endLabel =
        event.endDate != null ? _formatDate(event.endDate!) : '?';
    final dateRange = '$startLabel → $endLabel';

    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: hovered ? AppColors.hoverBackground : AppColors.background,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (happening)
                  Container(width: 3, color: const Color(0xFF4CAF50))
                else
                  const SizedBox(width: 3),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Tooltip(
                          message: 'Events complete automatically',
                          child: Container(
                            width: 18,
                            height: 18,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: happening
                                    ? const Color(0xFF4CAF50)
                                    : AppColors.muted,
                                width: 1.5,
                              ),
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.item.title,
                                style: AppTextStyles.itemTitle,
                              ),
                              if (event.item.notes != null &&
                                  event.item.notes!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  event.item.notes!,
                                  style: AppTextStyles.itemMeta,
                                ),
                              ],
                              const SizedBox(height: 2),
                              Text(dateRange, style: AppTextStyles.itemMeta),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventCaptureRow extends StatefulWidget {
  const _EventCaptureRow({required this.onSubmit});

  final void Function(String title, DateTime start, DateTime end) onSubmit;

  @override
  State<_EventCaptureRow> createState() => _EventCaptureRowState();
}

class _EventCaptureRowState extends State<_EventCaptureRow> {
  bool _expanded = false;
  bool _promptHovered = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _expand() {
    final now = DateTime.now();
    setState(() {
      _expanded = true;
      _startDate = now;
      _endDate = now.add(const Duration(hours: 1));
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      widget.onSubmit(title, _startDate, _endDate);
    }
    _controller.clear();
    setState(() => _expanded = false);
  }

  void _cancel() {
    _controller.clear();
    setState(() => _expanded = false);
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: _datePickerTheme,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      });
    }
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
      builder: _datePickerTheme,
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Widget _datePickerTheme(BuildContext context, Widget? child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.accent,
                onPrimary: AppColors.primary,
              ),
        ),
        child: child!,
      );

  String _fmt(DateTime dt) =>
      '${dt.month}/${dt.day}/${dt.year.toString().substring(2)}';

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
                Text('Add event', style: AppTextStyles.bodyMuted),
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
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
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
                      hintText: 'Event name',
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
          Row(
            children: [
              _DateChip(
                label: _fmt(_startDate),
                icon: Icons.play_circle_outline,
                onTap: _pickStart,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Text('→', style: AppTextStyles.itemMeta),
              ),
              _DateChip(
                label: _fmt(_endDate),
                icon: Icons.stop_circle_outlined,
                onTap: _pickEnd,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            Icon(icon, size: 12, color: AppColors.muted),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.itemMeta),
          ],
        ),
      ),
    );
  }
}

class _DeadlinesContent extends ConsumerStatefulWidget {
  const _DeadlinesContent();

  @override
  ConsumerState<_DeadlinesContent> createState() => _DeadlinesContentState();
}

class _DeadlinesContentState extends ConsumerState<_DeadlinesContent> {
  @override
  Widget build(BuildContext context) {
    final deadlinesAsync = ref.watch(activeDeadlinesProvider);

    return deadlinesAsync.when(
      loading: () => const _ShimmerList(),
      error: (e, _) => Center(
        child: Text(
          'Something went wrong: $e',
          style: AppTextStyles.bodyMuted,
          textAlign: TextAlign.center,
        ),
      ),
      data: (deadlines) => _DeadlineList(deadlines: deadlines),
    );
  }
}

class _DeadlineList extends ConsumerStatefulWidget {
  const _DeadlineList({required this.deadlines});

  final List<DeadlineWithDate> deadlines;

  @override
  ConsumerState<_DeadlineList> createState() => _DeadlineListState();
}

class _DeadlineListState extends ConsumerState<_DeadlineList> {
  int? _hoveredId;

  Future<void> _insert(String title, DateTime date) async {
    await ref.read(appDatabaseProvider).deadlinesDao.insertDeadline(title, date);
  }

  Future<void> _complete(int id) async {
    await ref.read(appDatabaseProvider).deadlinesDao.markComplete(id);
  }

  @override
  Widget build(BuildContext context) {
    final deadlines = widget.deadlines;
    final itemCount = deadlines.isEmpty ? 2 : deadlines.length + 1;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (deadlines.isEmpty) {
          if (index == 0) {
            return const _EmptyState(message: 'No active deadlines');
          }
          return _DeadlineCaptureRow(onSubmit: _insert);
        }

        if (index == deadlines.length) {
          return _DeadlineCaptureRow(onSubmit: _insert);
        }

        final deadline = deadlines[index];
        return _DeadlineRow(
          deadline: deadline,
          hovered: _hoveredId == deadline.item.id,
          onHoverChanged: (on) =>
              setState(() => _hoveredId = on ? deadline.item.id : null),
          onComplete: () => _complete(deadline.item.id),
        );
      },
    );
  }
}

Color _urgencyColor(DateTime? endDate) {
  if (endDate == null) return AppColors.muted;
  final days = endDate.difference(DateTime.now()).inDays;
  if (days < 3) return const Color(0xFFE53935);
  if (days < 7) return const Color(0xFFFB8C00);
  return const Color(0xFF43A047);
}

String _formatDate(DateTime dt) =>
    '${dt.month}/${dt.day}/${dt.year.toString().substring(2)}';

class _DeadlineRow extends StatelessWidget {
  const _DeadlineRow({
    required this.deadline,
    required this.hovered,
    required this.onHoverChanged,
    required this.onComplete,
  });

  final DeadlineWithDate deadline;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final dateColor = _urgencyColor(deadline.endDate);
    final dateLabel =
        deadline.endDate != null ? _formatDate(deadline.endDate!) : '—';

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
                    border: Border.all(color: dateColor, width: 1.5),
                    color: Colors.transparent,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deadline.item.title, style: AppTextStyles.itemTitle),
                    if (deadline.item.notes != null &&
                        deadline.item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(deadline.item.notes!, style: AppTextStyles.itemMeta),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                dateLabel,
                style: AppTextStyles.itemMeta.copyWith(color: dateColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeadlineCaptureRow extends StatefulWidget {
  const _DeadlineCaptureRow({required this.onSubmit});

  final void Function(String title, DateTime date) onSubmit;

  @override
  State<_DeadlineCaptureRow> createState() => _DeadlineCaptureRowState();
}

class _DeadlineCaptureRowState extends State<_DeadlineCaptureRow> {
  bool _expanded = false;
  bool _promptHovered = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  DateTime _pickedDate = DateTime.now();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() {
      _expanded = true;
      _pickedDate = DateTime.now();
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) widget.onSubmit(title, _pickedDate);
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
      firstDate: DateTime.now(),
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
                Text('Add deadline', style: AppTextStyles.bodyMuted),
              ],
            ),
          ),
        ),
      );
    }

    final dateColor = _urgencyColor(_pickedDate);

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
                      hintText: 'Deadline name',
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
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: dateColor.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: dateColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(_pickedDate),
                    style: AppTextStyles.itemMeta.copyWith(color: dateColor),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Center(
        child: Text(message, style: AppTextStyles.bodyMuted),
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
      itemCount: 4,
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
            width: 40,
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
