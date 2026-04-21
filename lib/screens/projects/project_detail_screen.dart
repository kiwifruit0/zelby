import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/database_provider.dart';
import '../../providers/projects_provider.dart';
import '../../theme/app_theme.dart';

// Item types that live inside projects.
const _kGroupOrder = [
  'unscheduled_task',
  'scheduled_task',
  'event',
  'deadline',
  'project',
];

const _kGroupLabels = {
  'unscheduled_task': 'Tasks',
  'scheduled_task': 'Scheduled',
  'event': 'Events',
  'deadline': 'Deadlines',
  'project': 'Sub-projects',
};

String _fmt(DateTime dt) =>
    '${dt.month}/${dt.day}/${dt.year.toString().substring(2)}';

Color _urgencyColor(DateTime? endDate) {
  if (endDate == null) return AppColors.muted;
  final days = endDate.difference(DateTime.now()).inDays;
  if (days < 3) return const Color(0xFFE53935);
  if (days <= 7) return const Color(0xFFFB8C00);
  return const Color(0xFF43A047);
}

// ── Screen ───────────────────────────────────────────────────────────────────

class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final int projectId;

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  Future<void> _onComplete(ProjectItemWithDate item) async {
    final db = ref.read(appDatabaseProvider);
    switch (item.itemType) {
      case 'unscheduled_task':
        await db.inboxDao.markComplete(item.item.id);
      case 'scheduled_task':
        await db.scheduledTasksDao.markComplete(item.item.id);
      case 'deadline':
        await db.deadlinesDao.markComplete(item.item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectItemsProvider(widget.projectId));

    return projectAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Project not found', style: AppTextStyles.bodyMuted),
      ),
      data: (data) => _ProjectDetailContent(
        data: data,
        projectId: widget.projectId,
        onComplete: _onComplete,
        onNavigateToProject: (id) => context.go('/projects/$id'),
      ),
    );
  }
}

// ── Detail content (owns the scroll + add bar) ───────────────────────────────

class _ProjectDetailContent extends StatelessWidget {
  const _ProjectDetailContent({
    required this.data,
    required this.projectId,
    required this.onComplete,
    required this.onNavigateToProject,
  });

  final ProjectWithItems data;
  final int projectId;
  final Future<void> Function(ProjectItemWithDate) onComplete;
  final void Function(int) onNavigateToProject;

  @override
  Widget build(BuildContext context) {
    // Group items by type, preserving the canonical display order.
    final grouped = <String, List<ProjectItemWithDate>>{};
    for (final item in data.items) {
      grouped.putIfAbsent(item.itemType, () => []).add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back navigation + project heading.
        _ProjectHeading(
          title: data.project.title,
          onBack: () => context.go('/projects'),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final type in _kGroupOrder)
                if (grouped.containsKey(type))
                  _GroupSection(
                    label: _kGroupLabels[type] ?? type,
                    items: grouped[type]!,
                    itemType: type,
                    onComplete: onComplete,
                    onNavigateToProject: onNavigateToProject,
                  ),
              _AddItemBar(projectId: projectId),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Project heading with back button ─────────────────────────────────────────

class _ProjectHeading extends StatelessWidget {
  const _ProjectHeading({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          // Back button.
          GestureDetector(
            onTap: onBack,
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Icon(Icons.chevron_left, size: 22, color: AppColors.muted),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.pageTitle.copyWith(fontSize: 40),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Collapsible group section ─────────────────────────────────────────────────

class _GroupSection extends StatefulWidget {
  const _GroupSection({
    required this.label,
    required this.items,
    required this.itemType,
    required this.onComplete,
    required this.onNavigateToProject,
  });

  final String label;
  final List<ProjectItemWithDate> items;
  final String itemType;
  final Future<void> Function(ProjectItemWithDate) onComplete;
  final void Function(int) onNavigateToProject;

  @override
  State<_GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<_GroupSection> {
  bool _expanded = true;
  // Single parent-owned hover key — only one row highlighted at a time.
  int? _hoveredId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          label: widget.label,
          count: widget.items.length,
          isExpanded: _expanded,
          onToggle: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded)
          for (final item in widget.items)
            _ItemRow(
              item: item,
              hovered: _hoveredId == item.item.id,
              onHoverChanged: (on) =>
                  setState(() => _hoveredId = on ? item.item.id : null),
              onComplete: () => widget.onComplete(item),
              onNavigate: item.itemType == 'project'
                  ? () => widget.onNavigateToProject(item.item.id)
                  : null,
            ),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.isExpanded,
    required this.onToggle,
  });

  final String label;
  final int count;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.expand_more : Icons.chevron_right,
              size: 14,
              color: AppColors.muted,
            ),
            const SizedBox(width: 4),
            Text(label.toUpperCase(), style: AppTextStyles.sectionHeader),
            const SizedBox(width: AppSpacing.xs),
            Text('$count', style: AppTextStyles.itemMeta),
          ],
        ),
      ),
    );
  }
}

// ── Generic item row (renders based on itemType) ──────────────────────────────

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.hovered,
    required this.onHoverChanged,
    required this.onComplete,
    this.onNavigate,
  });

  final ProjectItemWithDate item;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onComplete;
  final VoidCallback? onNavigate;

  bool _isEventHappening() {
    final now = DateTime.now();
    final s = item.startDate;
    final e = item.endDate;
    if (s == null || e == null) return false;
    return !now.isBefore(s) && !now.isAfter(e);
  }

  @override
  Widget build(BuildContext context) {
    final type = item.itemType;
    final happening = type == 'event' && _isEventHappening();

    Widget leadingIcon;
    VoidCallback? iconTap;

    if (type == 'event') {
      leadingIcon = Tooltip(
        message: 'Events complete automatically',
        child: Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: happening ? const Color(0xFF4CAF50) : AppColors.muted,
              width: 1.5,
            ),
          ),
        ),
      );
    } else if (type == 'project') {
      leadingIcon = SizedBox(
        width: 18,
        height: 18,
        child: Stack(
          children: [
            const Icon(Icons.folder_outlined, size: 18, color: AppColors.muted),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // task or deadline: circle checkbox
      final borderColor = type == 'deadline'
          ? _urgencyColor(item.endDate)
          : AppColors.muted;
      leadingIcon = Container(
        width: 18,
        height: 18,
        margin: const EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.5),
          color: Colors.transparent,
        ),
      );
      iconTap = type != 'scheduled_task' ? onComplete : onComplete;
    }

    Widget meta = const SizedBox.shrink();
    if (type == 'event') {
      final s = item.startDate;
      final e = item.endDate;
      if (s != null && e != null) {
        meta = Text('${_fmt(s)} → ${_fmt(e)}', style: AppTextStyles.itemMeta);
      }
    } else if (type == 'deadline' && item.endDate != null) {
      meta = Text(
        _fmt(item.endDate!),
        style: AppTextStyles.itemMeta.copyWith(
          color: _urgencyColor(item.endDate),
        ),
      );
    } else if (type == 'scheduled_task' && item.endDate != null) {
      meta = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 11, color: AppColors.muted),
          const SizedBox(width: 3),
          Text(_fmt(item.endDate!), style: AppTextStyles.itemMeta),
        ],
      );
    }

    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onNavigate,
        child: Container(
          color: hovered ? AppColors.hoverBackground : AppColors.background,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(onTap: iconTap, child: leadingIcon),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.item.title, style: AppTextStyles.itemTitle),
                    if (item.item.notes != null &&
                        item.item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(item.item.notes!, style: AppTextStyles.itemMeta),
                    ],
                    if (meta is! SizedBox) ...[const SizedBox(height: 2), meta],
                  ],
                ),
              ),
              if (type == 'deadline' && item.endDate != null)
                Text(
                  _fmt(item.endDate!),
                  style: AppTextStyles.itemMeta.copyWith(
                    color: _urgencyColor(item.endDate),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add item bar ──────────────────────────────────────────────────────────────

enum _NewItemType { task, event, deadline, subProject }

class _AddItemBar extends ConsumerStatefulWidget {
  const _AddItemBar({required this.projectId});

  final int projectId;

  @override
  ConsumerState<_AddItemBar> createState() => _AddItemBarState();
}

class _AddItemBarState extends ConsumerState<_AddItemBar> {
  bool _promptHovered = false;
  bool _showTypeSelector = false;
  _NewItemType? _selectedType;

  final _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  DateTime _dueDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _reset() {
    _titleController.clear();
    final now = DateTime.now();
    setState(() {
      _selectedType = null;
      _showTypeSelector = false;
      _startDate = now;
      _endDate = now.add(const Duration(hours: 1));
      _dueDate = now;
    });
  }

  void _selectType(_NewItemType type) {
    setState(() {
      _selectedType = type;
      _showTypeSelector = false;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _titleFocusNode.requestFocus(),
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final db = ref.read(appDatabaseProvider);
    final int itemId;
    final String itemTypeStr;

    switch (_selectedType!) {
      case _NewItemType.task:
        itemId = await db.inboxDao.insertTask(title);
        itemTypeStr = 'unscheduled_task';
      case _NewItemType.event:
        itemId = await db.eventsDao.insertEvent(title, _startDate, _endDate);
        itemTypeStr = 'event';
      case _NewItemType.deadline:
        itemId = await db.deadlinesDao.insertDeadline(title, _dueDate);
        itemTypeStr = 'deadline';
      case _NewItemType.subProject:
        itemId = await db.projectsDao.insertProject(title);
        itemTypeStr = 'project';
    }

    await db.projectsDao.addItemToProject(
      widget.projectId,
      itemId,
      itemTypeStr,
    );
    _reset();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : (_dueDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      } else {
        _dueDate = picked;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
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
    if (picked != null) setState(() => _endDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    if (!_showTypeSelector && _selectedType == null) {
      return _buildPrompt();
    }
    if (_showTypeSelector) {
      return _buildTypeSelector();
    }
    return _buildForm();
  }

  Widget _buildPrompt() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _promptHovered = true),
      onExit: (_) => setState(() => _promptHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _showTypeSelector = true),
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
              Text('Add item', style: AppTextStyles.bodyMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          for (final (type, label) in [
            (_NewItemType.task, 'Task'),
            (_NewItemType.event, 'Event'),
            (_NewItemType.deadline, 'Deadline'),
            (_NewItemType.subProject, 'Project'),
          ]) ...[
            _TypeChip(label: label, onTap: () => _selectType(type)),
            const SizedBox(width: AppSpacing.xs),
          ],
          const Spacer(),
          GestureDetector(
            onTap: _reset,
            child: const Icon(Icons.close, size: 16, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
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
              _typeLeadingIcon(_selectedType!),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.escape) {
                      _reset();
                    }
                  },
                  child: TextField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    style: AppTextStyles.itemTitle,
                    decoration: InputDecoration(
                      hintText: _hintForType(_selectedType!),
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
          if (_selectedType == _NewItemType.event) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                _DateChip(
                  label: _fmt(_startDate),
                  icon: Icons.play_circle_outline,
                  onTap: () => _pickDate(isStart: true),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Text('→', style: AppTextStyles.itemMeta),
                ),
                _DateChip(
                  label: _fmt(_endDate),
                  icon: Icons.stop_circle_outlined,
                  onTap: _pickEndDate,
                ),
              ],
            ),
          ] else if (_selectedType == _NewItemType.deadline) ...[
            const SizedBox(height: AppSpacing.xs),
            _DateChip(
              label: _fmt(_dueDate),
              icon: Icons.calendar_today_outlined,
              onTap: () => _pickDate(isStart: false),
            ),
          ],
        ],
      ),
    );
  }

  Widget _typeLeadingIcon(_NewItemType type) {
    if (type == _NewItemType.event) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppColors.muted.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
      );
    }
    if (type == _NewItemType.subProject) {
      return const Icon(
        Icons.folder_outlined,
        size: 18,
        color: AppColors.muted,
      );
    }
    // task / deadline — circle
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.muted.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
    );
  }

  String _hintForType(_NewItemType type) => switch (type) {
    _NewItemType.task => 'Task name',
    _NewItemType.event => 'Event name',
    _NewItemType.deadline => 'Deadline name',
    _NewItemType.subProject => 'Sub-project name',
  };
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: AppTextStyles.itemMeta),
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
