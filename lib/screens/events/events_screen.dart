import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/database_provider.dart';
import '../../providers/events_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/smooth_scroll.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  @override
  void initState() {
    super.initState();
    // Mark any events whose end date has already passed as complete.
    ref.read(appDatabaseProvider).eventsDao.autoCompleteExpiredEvents();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

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
          child: Text('Events', style: AppTextStyles.pageTitle),
        ),
        Expanded(
          child: eventsAsync.when(
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
          ),
        ),
      ],
    );
  }
}

// ── Event list ───────────────────────────────────────────────────────────────

class _EventList extends ConsumerStatefulWidget {
  const _EventList({required this.events});

  final List<EventWithDates> events;

  @override
  ConsumerState<_EventList> createState() => _EventListState();
}

class _EventListState extends ConsumerState<_EventList> {
  // Single parent-owned hover key — only one row highlighted at a time.
  int? _hoveredId;

  Future<void> _insert(String title, DateTime start, DateTime end) async {
    await ref
        .read(appDatabaseProvider)
        .eventsDao
        .insertEvent(title, start, end);
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.events;
    final itemCount = events.isEmpty ? 2 : events.length + 1;

    return SmoothListView.builder(
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (events.isEmpty) {
          if (index == 0) return const _EmptyState();
          return _CaptureRow(onSubmit: _insert);
        }

        if (index == events.length) {
          return _CaptureRow(onSubmit: _insert);
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

// ── Individual event row ─────────────────────────────────────────────────────

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
    final startLabel = event.startDate != null
        ? _formatDate(event.startDate!)
        : '?';
    final endLabel = event.endDate != null ? _formatDate(event.endDate!) : '?';
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
                // Active-event left border accent.
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
                        // Rounded-square icon — events auto-complete, no tap action.
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

// ── Capture row ──────────────────────────────────────────────────────────────

class _CaptureRow extends StatefulWidget {
  const _CaptureRow({required this.onSubmit});

  final void Function(String title, DateTime start, DateTime end) onSubmit;

  @override
  State<_CaptureRow> createState() => _CaptureRowState();
}

class _CaptureRowState extends State<_CaptureRow> {
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
              // Rounded square placeholder matching event rows.
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
        child: Text('No upcoming events', style: AppTextStyles.bodyMuted),
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
              borderRadius: BorderRadius.circular(4),
              color: AppColors.divider,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
