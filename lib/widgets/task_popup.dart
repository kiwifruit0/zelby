import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../database/database.dart' as db;
import '../providers/inbox_provider.dart';
import '../providers/deadlines_provider.dart';
import '../providers/events_provider.dart';
import '../providers/projects_provider.dart';
import '../theme/app_theme.dart';

enum TaskDestinationKind { inbox, project, event, deadline }

class TaskDestinationSelection {
  const TaskDestinationSelection._({
    required this.kind,
    required this.label,
    required this.icon,
    this.itemId,
  });

  const TaskDestinationSelection.inbox()
    : this._(
        kind: TaskDestinationKind.inbox,
        label: 'Inbox',
        icon: Icons.inbox_outlined,
      );

  const TaskDestinationSelection.project({
    required int itemId,
    required String label,
  }) : this._(
         kind: TaskDestinationKind.project,
         itemId: itemId,
         label: label,
         icon: Icons.folder_outlined,
       );

  const TaskDestinationSelection.event({
    required int itemId,
    required String label,
  }) : this._(
         kind: TaskDestinationKind.event,
         itemId: itemId,
         label: label,
         icon: Icons.event_outlined,
       );

  const TaskDestinationSelection.deadline({
    required int itemId,
    required String label,
  }) : this._(
         kind: TaskDestinationKind.deadline,
         itemId: itemId,
         label: label,
         icon: Icons.schedule_outlined,
       );

  final TaskDestinationKind kind;
  final int? itemId;
  final String label;
  final IconData icon;

  bool get isInbox => kind == TaskDestinationKind.inbox;
}

class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.destination,
    required this.date,
  });

  final String title;
  final DateTime? date;
  final TaskDestinationSelection destination;
}

class TaskAddPromptButton extends StatefulWidget {
  const TaskAddPromptButton({
    super.key,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    this.label = 'Add task',
    this.icon = Icons.add,
    this.trailingLabel,
  });

  final FutureOr<void> Function() onTap;
  final EdgeInsetsGeometry padding;
  final String label;
  final IconData icon;
  final String? trailingLabel;

  @override
  State<TaskAddPromptButton> createState() => _TaskAddPromptButtonState();
}

class _TaskAddPromptButtonState extends State<TaskAddPromptButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onTap();
        },
        child: Container(
          color: _hovered ? AppColors.hoverBackground : Colors.transparent,
          padding: widget.padding,
          child: Row(
            children: [
              Icon(widget.icon, size: 16, color: AppColors.muted),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(widget.label, style: AppTextStyles.bodyMuted),
              ),
              if (widget.trailingLabel != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(widget.trailingLabel!, style: AppTextStyles.itemMeta),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Future<TaskDraft?> showAddTaskDialog(
  BuildContext context, {
  DateTime? initialDate,
  TaskDestinationSelection initialDestination =
      const TaskDestinationSelection.inbox(),
}) {
  return showDialog<TaskDraft>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _AddTaskDialog(
      initialDate: initialDate ?? DateTime.now(),
      initialDestination: initialDestination,
    ),
  );
}

Future<DateTime?> showTaskDatePickerDialog(
  BuildContext context, {
  required DateTime initialDate,
}) {
  return showDialog<DateTime?>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _TaskDatePickerDialog(initialDate: initialDate),
  );
}

Future<TaskDestinationSelection?> showTaskDestinationPickerDialog(
  BuildContext context, {
  required TaskDestinationSelection initialDestination,
}) {
  return showDialog<TaskDestinationSelection?>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _TaskDestinationDialog(initialDestination: initialDestination),
  );
}

Future<void> persistTaskDraft(db.AppDatabase database, TaskDraft draft) async {
  final taskId = await database.inboxDao.insertTask(
    draft.title,
    endDate: draft.date,
  );

  switch (draft.destination.kind) {
    case TaskDestinationKind.inbox:
      return;
    case TaskDestinationKind.project:
      await database.projectsDao.addItemToProject(
        draft.destination.itemId!,
        taskId,
        'unscheduled_task',
      );
      return;
    case TaskDestinationKind.event:
    case TaskDestinationKind.deadline:
      await database.into(database.taskDependencies).insert(
        db.TaskDependenciesCompanion.insert(
          taskId: taskId,
          dependsOnId: draft.destination.itemId!,
        ),
      );
      return;
  }
}

class _AddTaskDialog extends ConsumerStatefulWidget {
  const _AddTaskDialog({
    required this.initialDate,
    required this.initialDestination,
  });

  final DateTime initialDate;
  final TaskDestinationSelection initialDestination;

  @override
  ConsumerState<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<_AddTaskDialog> {
  final _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();
  DateTime? _selectedDate;
  TaskDestinationSelection? _selectedDestination;
  bool _hoveredCancel = false;
  bool _hoveredSubmit = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _selectedDestination = widget.initialDestination;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _titleFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showTaskDatePickerDialog(
      context,
      initialDate: _selectedDate ?? DateTime.now(),
    );
    if (!mounted) return;
    setState(() => _selectedDate = picked);
  }

  Future<void> _pickDestination() async {
    final picked = await showTaskDestinationPickerDialog(
      context,
      initialDestination:
          _selectedDestination ?? const TaskDestinationSelection.inbox(),
    );
    if (!mounted || picked == null) return;
    setState(() => _selectedDestination = picked);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop(
      TaskDraft(
        title: title,
        date: _selectedDate,
        destination: _selectedDestination ?? const TaskDestinationSelection.inbox(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    if (date == normalizedToday) return 'Today';
    if (date == normalizedToday.add(const Duration(days: 1))) return 'Tomorrow';
    return '${date.month}/${date.day}/${date.year.toString().substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth = width < 720 ? width - 24 : 720.0;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          minWidth: width < 720 ? dialogWidth : 680,
          maxHeight: MediaQuery.sizeOf(context).height - 48,
        ),
        child: Material(
          color: AppColors.background,
          elevation: 0,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        style: AppTextStyles.pageTitle.copyWith(fontSize: 34),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          hintText: 'New task',
                          hintStyle: TextStyle(
                            color: Color(0xFFB0B0B0),
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Description',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.muted,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _ActionChip(
                            icon: Icons.calendar_today_outlined,
                            label: _formatDate(
                              _selectedDate ?? DateTime.now(),
                            ),
                            color: const Color(0xFF008A2E),
                            onTap: _pickDate,
                            trailingIcon: Icons.close,
                            trailingIconColor: Colors.black54,
                            onTrailingTap: () => setState(() => _selectedDate = null),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.divider),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: _DestinationButton(
                        destination:
                            _selectedDestination ?? const TaskDestinationSelection.inbox(),
                        onTap: _pickDestination,
                      ),
                    ),
                    const Spacer(),
                    _FooterButton(
                      label: 'Cancel',
                      hovered: _hoveredCancel,
                      onHoverChanged: (value) =>
                          setState(() => _hoveredCancel = value),
                      onTap: () => Navigator.of(context).pop(),
                      filled: false,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _FooterButton(
                      label: 'Add task',
                      hovered: _hoveredSubmit,
                      onHoverChanged: (value) =>
                          setState(() => _hoveredSubmit = value),
                      onTap: _submit,
                      filled: true,
                    ),
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

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.trailingIcon,
    this.trailingIconColor,
    this.onTrailingTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final IconData? trailingIcon;
  final Color? trailingIconColor;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.itemTitle.copyWith(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (trailingIcon != null && onTrailingTap != null) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onTrailingTap,
                child: Icon(
                  trailingIcon,
                  size: 18,
                  color: trailingIconColor ?? color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DisabledActionChip extends StatelessWidget {
  const _DisabledActionChip({
    required this.icon,
    required this.label,
    this.showNewBadge = false,
  });

  final IconData icon;
  final String label;
  final bool showNewBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTextStyles.itemTitle.copyWith(
              color: AppColors.muted,
              fontSize: 16,
            ),
          ),
          if (showNewBadge) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'NEW',
                style: AppTextStyles.sectionHeader.copyWith(
                  color: const Color(0xFF008A2E),
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DestinationButton extends StatelessWidget {
  const _DestinationButton({
    required this.destination,
    required this.onTap,
  });

  final TaskDestinationSelection destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            Icon(destination.icon, size: 20, color: AppColors.muted),
            const SizedBox(width: 10),
            Text(destination.label, style: AppTextStyles.itemTitle.copyWith(fontSize: 16)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({
    required this.label,
    required this.hovered,
    required this.onHoverChanged,
    required this.onTap,
    required this.filled,
  });

  final String label;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final background = filled
        ? (hovered ? AppColors.accent.withValues(alpha: 0.72) : AppColors.accent)
        : (hovered ? AppColors.hoverBackground : AppColors.background);
    final color = filled ? Colors.white : AppColors.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
            border: filled ? null : Border.all(color: AppColors.divider),
          ),
          child: Text(
            label,
            style: AppTextStyles.itemTitle.copyWith(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskDatePickerDialog extends StatefulWidget {
  const _TaskDatePickerDialog({required this.initialDate});

  final DateTime initialDate;

  @override
  State<_TaskDatePickerDialog> createState() => _TaskDatePickerDialogState();
}

class _TaskDatePickerDialogState extends State<_TaskDatePickerDialog> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
    _selectedDay = _focusedDay;
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _thisWeekend() {
    final today = _today();
    final offset = DateTime.saturday - today.weekday;
    return today.add(Duration(days: offset <= 0 ? offset + 7 : offset));
  }

  DateTime _nextMonday() {
    final today = _today();
    final offset = DateTime.monday - today.weekday;
    return today.add(Duration(days: offset <= 0 ? offset + 7 : offset));
  }

  String _labelFor(DateTime date) {
    final today = _today();
    final tomorrow = today.add(const Duration(days: 1));
    final normalized = DateTime(date.year, date.month, date.day);
    if (normalized == today) return 'Today';
    if (normalized == tomorrow) return 'Tomorrow';
    return '${date.month}/${date.day}/${date.year.toString().substring(2)}';
  }

  void _closeWith(DateTime? date) {
    Navigator.of(context).pop(date == null ? null : DateTime(date.year, date.month, date.day));
  }

  Widget _chipButton(
    String label,
    String trailing,
    VoidCallback onTap, {
    Color? labelColor,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.itemTitle.copyWith(
                fontSize: 18,
                color: labelColor ?? AppColors.primary,
              ),
            ),
            Text(trailing, style: AppTextStyles.bodyMuted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        child: Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedDay == null
                        ? 'No date'
                        : _labelFor(_selectedDay!),
                    style: AppTextStyles.pageTitle.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _chipButton(
                    'Tomorrow',
                    _labelFor(_today().add(const Duration(days: 1))),
                    () => _closeWith(_today().add(const Duration(days: 1))),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _chipButton(
                    'Later this week',
                    _labelFor(_today().add(const Duration(days: 2))),
                    () => _closeWith(_today().add(const Duration(days: 2))),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _chipButton(
                    'This weekend',
                    _labelFor(_thisWeekend()),
                    () => _closeWith(_thisWeekend()),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _chipButton(
                    'Next week',
                    _labelFor(_nextMonday()),
                    () => _closeWith(_nextMonday()),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _chipButton(
                    'No Date',
                    '',
                    () => _closeWith(null),
                    labelColor: AppColors.muted,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _closeWith(selectedDay);
                      },
                      onPageChanged: (focusedDay) {
                        setState(() => _focusedDay = focusedDay);
                      },
                      headerStyle: const HeaderStyle(
                        titleCentered: false,
                        formatButtonVisible: false,
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: AppColors.muted,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: AppColors.muted,
                        ),
                        titleTextStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        cellMargin: const EdgeInsets.all(4),
                        defaultDecoration: const BoxDecoration(),
                        weekendDecoration: const BoxDecoration(),
                        outsideDecoration: const BoxDecoration(),
                        disabledDecoration: const BoxDecoration(),
                        holidayDecoration: const BoxDecoration(),
                        selectedDecoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                        ),
                        todayDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accent,
                            width: 1.5,
                          ),
                        ),
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
                        markersMaxCount: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.access_time, size: 18),
                          label: const Text('Time'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.repeat, size: 18),
                          label: const Text('Repeat'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskDestinationDialog extends ConsumerStatefulWidget {
  const _TaskDestinationDialog({required this.initialDestination});

  final TaskDestinationSelection initialDestination;

  @override
  ConsumerState<_TaskDestinationDialog> createState() =>
      _TaskDestinationDialogState();
}

class _TaskDestinationDialogState extends ConsumerState<_TaskDestinationDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_DestinationRow> _buildRows(
    List<Item> projects,
    List<EventWithDates> events,
    List<DeadlineWithDate> deadlines,
  ) {
    final rows = <_DestinationRow>[
      ...projects.map(
        (project) => _DestinationRow(
          selection: TaskDestinationSelection.project(
            itemId: project.id,
            label: project.title,
          ),
          section: 'My Projects',
        ),
      ),
      ...events.map(
        (event) => _DestinationRow(
          selection: TaskDestinationSelection.event(
            itemId: event.item.id,
            label: event.item.title,
          ),
          section: 'Events',
        ),
      ),
      ...deadlines.map(
        (deadline) => _DestinationRow(
          selection: TaskDestinationSelection.deadline(
            itemId: deadline.item.id,
            label: deadline.item.title,
          ),
          section: 'Deadlines',
        ),
      ),
    ];

    if (_query.trim().isEmpty) return rows;
    final q = _query.toLowerCase();
    return rows
        .where(
          (row) =>
              row.selection.label.toLowerCase().contains(q) ||
              row.section.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(allProjectsProvider);
    final eventsAsync = ref.watch(upcomingEventsProvider);
    final deadlinesAsync = ref.watch(activeDeadlinesProvider);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Type a project name',
                    hintStyle: AppTextStyles.bodyMuted.copyWith(fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.accent),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: projectsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Center(
                      child: Text(
                        'Something went wrong: $e',
                        style: AppTextStyles.bodyMuted,
                      ),
                    ),
                    data: (projects) => eventsAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (e, _) => Center(
                        child: Text(
                          'Something went wrong: $e',
                          style: AppTextStyles.bodyMuted,
                        ),
                      ),
                      data: (events) => deadlinesAsync.when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (e, _) => Center(
                          child: Text(
                            'Something went wrong: $e',
                            style: AppTextStyles.bodyMuted,
                          ),
                        ),
                        data: (deadlines) {
                          final rows = _buildRows(projects, events, deadlines);
                          final filteredRows = [
                            const _DestinationRow(
                              selection: TaskDestinationSelection.inbox(),
                              section: 'Inbox',
                            ),
                            ...rows,
                          ].where((row) {
                            if (_query.trim().isEmpty) return true;
                            final q = _query.toLowerCase();
                            return row.selection.label.toLowerCase().contains(q) ||
                                row.section.toLowerCase().contains(q);
                          }).toList();

                          return ListView.separated(
                            itemCount: filteredRows.isEmpty ? 1 : filteredRows.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSpacing.xs),
                            itemBuilder: (context, index) {
                              if (filteredRows.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.lg,
                                  ),
                                  child: Text(
                                    'No matches',
                                    style: AppTextStyles.bodyMuted,
                                  ),
                                );
                              }

                              final row = filteredRows[index];
                              final selected = _matchesCurrentSelection(
                                row.selection,
                                widget.initialDestination,
                              );
                              return _DestinationRowTile(
                                selection: row.selection,
                                selected: selected,
                                onTap: () => Navigator.of(context).pop(row.selection),
                                section: row.section,
                              );
                            },
                          );
                        },
                      ),
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

  bool _matchesCurrentSelection(
    TaskDestinationSelection a,
    TaskDestinationSelection b,
  ) {
    return a.kind == b.kind && a.itemId == b.itemId;
  }
}

class _DestinationRow {
  const _DestinationRow({
    required this.selection,
    required this.section,
  });

  final TaskDestinationSelection selection;
  final String section;
}

class _DestinationRowTile extends StatelessWidget {
  const _DestinationRowTile({
    required this.selection,
    required this.selected,
    required this.onTap,
    required this.section,
  });

  final TaskDestinationSelection selection;
  final bool selected;
  final VoidCallback onTap;
  final String section;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.hoverBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  selection.icon,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selection.label, style: AppTextStyles.itemTitle),
                    Text(section, style: AppTextStyles.itemMeta),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check, size: 18, color: Color(0xFFE53935)),
            ],
          ),
        ),
      ),
    );
  }
}
