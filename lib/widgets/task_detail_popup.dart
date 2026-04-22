import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart' as db;
import '../database/daos/inbox_dao.dart';
import '../database/daos/projects_dao.dart';
import '../database/daos/events_dao.dart';
import '../database/daos/deadlines_dao.dart';
import '../providers/database_provider.dart';
import '../providers/inbox_provider.dart';
import '../providers/projects_provider.dart';
import '../providers/events_provider.dart';
import '../providers/deadlines_provider.dart';
import '../theme/app_theme.dart';
import 'task_popup.dart';

class TaskDetailParams {
  const TaskDetailParams({
    required this.taskId,
    this.taskIds = const [],
  });

  final int taskId;
  final List<int> taskIds;

  int get currentIndex => taskIds.indexOf(taskId);
  bool get hasNext => currentIndex < taskIds.length - 1;
  bool get hasPrevious => currentIndex > 0;
  int? get nextTaskId => hasNext ? taskIds[currentIndex + 1] : null;
  int? get previousTaskId => hasPrevious ? taskIds[currentIndex - 1] : null;
}

Future<TaskDetailResult?> showTaskDetailDialog(
  BuildContext context,
  TaskDetailParams params,
) {
  return showDialog<TaskDetailResult>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _TaskDetailDialog(params: params),
  );
}

class TaskDetailResult {
  const TaskDetailResult._({
    this.updated = false,
    this.deleted = false,
    this.completed = false,
    this.nextTaskId,
  });

  final bool updated;
  final bool deleted;
  final bool completed;
  final int? nextTaskId;

  factory TaskDetailResult.updated() => const TaskDetailResult._(updated: true);
  factory TaskDetailResult.deleted() => const TaskDetailResult._(deleted: true);
  factory TaskDetailResult.completed() => const TaskDetailResult._(completed: true);
  factory TaskDetailResult.next(int taskId) => TaskDetailResult._(nextTaskId: taskId);
}

class _TaskDetailDialog extends ConsumerStatefulWidget {
  const _TaskDetailDialog({required this.params});

  final TaskDetailParams params;

  @override
  ConsumerState<_TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends ConsumerState<_TaskDetailDialog> {
  late int _currentTaskId;
  bool _isLoading = true;
  db.Item? _task;
  db.ItemDate? _taskDate;
  int? _projectId;
  String? _projectName;
  List<db.Item> _dependencies = [];
  List<db.Item> _linkedEvents = [];
  List<db.Item> _linkedDeadlines = [];

  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  bool _titleChanged = false;
  bool _notesChanged = false;

  @override
  void initState() {
    super.initState();
    _currentTaskId = widget.params.taskId;
    _loadTask();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    setState(() => _isLoading = true);

    final db = ref.read(appDatabaseProvider);
    final inboxDao = InboxDao(db);
    final projectsDao = ProjectsDao(db);
    final eventsDao = EventsDao(db);
    final deadlinesDao = DeadlinesDao(db);

    final task = await inboxDao.getTaskById(_currentTaskId);
    if (task == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    _titleController.text = task.title;
    _notesController.text = task.notes ?? '';
    _titleChanged = false;
    _notesChanged = false;

    final taskDate = await inboxDao.getItemDate(_currentTaskId);
    final project = await projectsDao.getProjectForItem(_currentTaskId);

    final deps = await inboxDao.getDependencies(_currentTaskId);
    final linkedEvts = await eventsDao.getEventsForTask(_currentTaskId);
    final linkedDl = await deadlinesDao.getDeadlinesForTask(_currentTaskId);

    setState(() {
      _task = task;
      _taskDate = taskDate;
      _projectId = project?.itemId;
      _projectName = project?.projectName;
      _dependencies = deps;
      _linkedEvents = linkedEvts;
      _linkedDeadlines = linkedDl;
      _isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    if (!_titleChanged && !_notesChanged) return;

    final db = ref.read(appDatabaseProvider);
    final inboxDao = InboxDao(db);

    if (_titleChanged && _titleController.text.trim().isNotEmpty) {
      await inboxDao.updateTask(_currentTaskId, title: _titleController.text.trim());
    }
    if (_notesChanged) {
      await inboxDao.updateTask(_currentTaskId, notes: _notesController.text.trim());
    }
  }

  Future<void> _navigateTo(int taskId) async {
    await _saveChanges();
    setState(() {
      _currentTaskId = taskId;
      _isLoading = true;
    });
    _loadTask();
  }

  Future<void> _markComplete() async {
    await _saveChanges();
    final db = ref.read(appDatabaseProvider);
    await InboxDao(db).markComplete(_currentTaskId);
    if (mounted) {
      Navigator.of(context).pop(TaskDetailResult.completed());
    }
  }

  Future<void> _deleteTask() async {
    await _saveChanges();
    final db = ref.read(appDatabaseProvider);
    await InboxDao(db).softDelete(_currentTaskId);
    if (mounted) {
      Navigator.of(context).pop(TaskDetailResult.deleted());
    }
  }

  Future<void> _pickDate() async {
    final picked = await showTaskDatePickerDialog(
      context,
      initialDate: _taskDate?.endDate ?? DateTime.now(),
    );
    if (!mounted || picked == null) return;

    final db = ref.read(appDatabaseProvider);
    final inboxDao = InboxDao(db);
    await inboxDao.setTaskDate(_currentTaskId, endDate: picked);
    _loadTask();
  }

  Future<void> _pickProject() async {
    final picked = await showProjectPickerDialog(
      context,
      initialProjectId: _projectId,
    );
    if (!mounted || picked == null) return;

    final db = ref.read(appDatabaseProvider);
    final projectsDao = ProjectsDao(db);

    if (_projectId != null) {
      await projectsDao.removeItemFromProject(_projectId!, _currentTaskId);
    }

    if (picked != -1) {
      await projectsDao.addItemToProject(picked, _currentTaskId, 'unscheduled_task');
    }

    _loadTask();
  }

  Future<void> _removeDate() async {
    final db = ref.read(appDatabaseProvider);
    final inboxDao = InboxDao(db);
    await inboxDao.removeTaskDate(_currentTaskId);
    _loadTask();
  }

  Future<void> _addDependency() async {
    final result = await showLinkTaskDialog(
      context,
      excludeTaskId: _currentTaskId,
    );
    if (!mounted || result == null) return;

    final db = ref.read(appDatabaseProvider);
    final inboxDao = InboxDao(db);

    if (result.type == LinkTaskResultType.createNew) {
      final newTaskId = await inboxDao.insertTask(result.title ?? '');
      await inboxDao.addDependency(_currentTaskId, newTaskId);
    } else if (result.existingTaskId != null) {
      await inboxDao.addDependency(_currentTaskId, result.existingTaskId!);
    }

    _loadTask();
  }

  Future<void> _removeDependency(int dependsOnId) async {
    final db = ref.read(appDatabaseProvider);
    final inboxDao = InboxDao(db);
    await inboxDao.removeDependency(_currentTaskId, dependsOnId);
    _loadTask();
  }

  Future<void> _linkToEvent() async {
    final result = await showLinkEventDeadlineDialog(
      context,
      type: LinkEventDeadlineType.event,
    );
    if (!mounted || result == null || result.itemId == null) return;

    final db = ref.read(appDatabaseProvider);
    final inboxDao = InboxDao(db);
    await inboxDao.addDependency(_currentTaskId, result.itemId!);
    _loadTask();
  }

  Future<void> _linkToDeadline() async {
    final result = await showLinkEventDeadlineDialog(
      context,
      type: LinkEventDeadlineType.deadline,
    );
    if (!mounted || result == null || result.itemId == null) return;

    final db = ref.read(appDatabaseProvider);
    final inboxDao = InboxDao(db);
    await inboxDao.addDependency(_currentTaskId, result.itemId!);
    _loadTask();
  }

  Future<void> _unlinkEvent(int eventId) async {
    final db = ref.read(appDatabaseProvider);
    final inboxDao = InboxDao(db);
    await inboxDao.removeDependency(_currentTaskId, eventId);
    _loadTask();
  }

  Future<void> _unlinkDeadline(int deadlineId) async {
    final db = ref.read(appDatabaseProvider);
    final inboxDao = InboxDao(db);
    await inboxDao.removeDependency(_currentTaskId, deadlineId);
    _loadTask();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth = width < 800 ? width - 24 : 800.0;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          minWidth: width < 800 ? dialogWidth : 720,
          maxHeight: MediaQuery.sizeOf(context).height - 48,
        ),
        child: Material(
          color: AppColors.background,
          elevation: 0,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: _isLoading
              ? const SizedBox(
                  width: 300,
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTopBar(),
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTitleSection(),
                                  const SizedBox(height: AppSpacing.md),
                                  _buildNotesSection(),
                                  const SizedBox(height: AppSpacing.lg),
                                  const Divider(),
                                  const SizedBox(height: AppSpacing.md),
                                  _buildLinkSection(),
                                  const SizedBox(height: AppSpacing.md),
                                  _buildLinkedItemsList(),
                                  const SizedBox(height: AppSpacing.lg),
                                  const Divider(),
                                  const SizedBox(height: AppSpacing.md),
                                  _buildBottomButtons(),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 220,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProjectSelector(),
                                  const SizedBox(height: AppSpacing.md),
                                  _buildDateSelector(),
                                  const SizedBox(height: AppSpacing.md),
                                  _buildDeadlineLink(),
                                ],
                              ),
                            ),
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

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _projectName ?? 'Inbox',
              style: AppTextStyles.bodyMuted,
            ),
          ),
          _NavigationButton(
            icon: Icons.keyboard_arrow_up,
            enabled: widget.params.hasPrevious,
            onTap: widget.params.hasPrevious
                ? () => _navigateTo(widget.params.previousTaskId!)
                : null,
          ),
          _NavigationButton(
            icon: Icons.keyboard_arrow_down,
            enabled: widget.params.hasNext,
            onTap: widget.params.hasNext
                ? () => _navigateTo(widget.params.nextTaskId!)
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          _NavigationButton(
            icon: Icons.close,
            enabled: true,
            onTap: () async {
              await _saveChanges();
              if (mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _markComplete,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _task?.completed == true
                    ? const Color(0xFF008A2E)
                    : AppColors.muted,
                width: 1.5,
              ),
              color: _task?.completed == true
                  ? const Color(0xFF008A2E)
                  : Colors.transparent,
            ),
            child: _task?.completed == true
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: TextField(
            controller: _titleController,
            style: AppTextStyles.pageTitle.copyWith(fontSize: 22),
            decoration: const InputDecoration(
              hintText: 'Task title',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (_) => setState(() => _titleChanged = true),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: TextField(
        controller: _notesController,
        style: AppTextStyles.body,
        maxLines: null,
        decoration: InputDecoration(
          hintText: 'Add description...',
          hintStyle: AppTextStyles.bodyMuted,
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (_) => setState(() => _notesChanged = true),
      ),
    );
  }

  Widget _buildLinkSection() {
    return _SidebarButton(
      icon: Icons.add,
      label: 'Link to task',
      onTap: _addDependency,
    );
  }

  Widget _buildLinkedItemsList() {
    final allLinked = <_LinkedItem>[];

    for (final dep in _dependencies) {
      allLinked.add(_LinkedItem(
        id: dep.id,
        title: dep.title,
        type: _LinkedItemType.dependency,
      ));
    }

    for (final evt in _linkedEvents) {
      allLinked.add(_LinkedItem(
        id: evt.id,
        title: evt.title,
        type: _LinkedItemType.event,
      ));
    }

    for (final dl in _linkedDeadlines) {
      allLinked.add(_LinkedItem(
        id: dl.id,
        title: dl.title,
        type: _LinkedItemType.deadline,
      ));
    }

    if (allLinked.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LINKED', style: AppTextStyles.sectionHeader),
        const SizedBox(height: AppSpacing.sm),
        ...allLinked.map((item) => _LinkedItemRow(
              item: item,
              onRemove: () {
                switch (item.type) {
                  case _LinkedItemType.dependency:
                    _removeDependency(item.id);
                    break;
                  case _LinkedItemType.event:
                    _unlinkEvent(item.id);
                    break;
                  case _LinkedItemType.deadline:
                    _unlinkDeadline(item.id);
                    break;
                }
              },
            )),
      ],
    );
  }

  Widget _buildProjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PROJECT', style: AppTextStyles.sectionHeader),
        const SizedBox(height: AppSpacing.xs),
        _SidebarButton(
          icon: Icons.folder_outlined,
          label: _projectName ?? 'Inbox',
          onTap: _pickProject,
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DATE', style: AppTextStyles.sectionHeader),
        const SizedBox(height: AppSpacing.xs),
        _SidebarButton(
          icon: Icons.event_outlined,
          label: _taskDate?.endDate != null
              ? _formatDate(_taskDate!.endDate!)
              : 'No date',
          onTap: _pickDate,
        ),
        if (_taskDate?.endDate != null) ...[
          const SizedBox(height: AppSpacing.xs),
          _SidebarButton(
            icon: Icons.close,
            label: 'Remove date',
            onTap: _removeDate,
          ),
        ],
      ],
    );
  }

  Widget _buildDeadlineLink() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LINK TO', style: AppTextStyles.sectionHeader),
        const SizedBox(height: AppSpacing.xs),
        _SidebarButton(
          icon: Icons.event_outlined,
          label: 'Event',
          onTap: _linkToEvent,
        ),
        const SizedBox(height: AppSpacing.xs),
        _SidebarButton(
          icon: Icons.schedule_outlined,
          label: 'Deadline',
          onTap: _linkToDeadline,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    if (date == normalizedToday) return 'Today';
    if (date == normalizedToday.add(const Duration(days: 1))) return 'Tomorrow';
    return '${date.month}/${date.day}/${date.year.toString().substring(2)}';
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        _SidebarButton(
          icon: Icons.label_outline,
          label: 'Labels',
          onTap: () {},
          enabled: false,
        ),
        const SizedBox(width: AppSpacing.sm),
        _SidebarButton(
          icon: Icons.notifications_outlined,
          label: 'Reminders',
          onTap: () {},
          enabled: false,
        ),
        const Spacer(),
        TextButton(
          onPressed: _deleteTask,
          child: Text(
            'Delete task',
            style: AppTextStyles.body.copyWith(color: const Color(0xFFE53935)),
          ),
        ),
      ],
    );
  }
}

class _NavigationButton extends StatefulWidget {
  const _NavigationButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.enabled
        ? (_hovered ? AppColors.accent : AppColors.muted)
        : AppColors.divider;

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? widget.onTap : null,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Icon(widget.icon, size: 20, color: color),
        ),
      ),
    );
  }
}

class _SidebarButton extends StatefulWidget {
  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<_SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<_SidebarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.enabled
        ? (_hovered ? AppColors.accent : AppColors.muted)
        : AppColors.divider;

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? widget.onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                widget.label,
                style: AppTextStyles.body.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _LinkedItemType { dependency, event, deadline }

class _LinkedItem {
  const _LinkedItem({
    required this.id,
    required this.title,
    required this.type,
  });

  final int id;
  final String title;
  final _LinkedItemType type;
}

class _LinkedItemRow extends StatefulWidget {
  const _LinkedItemRow({required this.item, required this.onRemove});

  final _LinkedItem item;
  final VoidCallback onRemove;

  @override
  State<_LinkedItemRow> createState() => _LinkedItemRowState();
}

class _LinkedItemRowState extends State<_LinkedItemRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (widget.item.type) {
      case _LinkedItemType.dependency:
        icon = Icons.subdirectory_arrow_right;
        break;
      case _LinkedItemType.event:
        icon = Icons.event_outlined;
        break;
      case _LinkedItemType.deadline:
        icon = Icons.schedule_outlined;
        break;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onRemove,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          color: _hovered ? AppColors.hoverBackground : Colors.transparent,
          child: Row(
            children: [
              Icon(icon, size: 14, color: AppColors.muted),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.item.title,
                  style: AppTextStyles.body,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_hovered)
                const Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<int?> showProjectPickerDialog(
  BuildContext context, {
  int? initialProjectId,
}) async {
  return showDialog<int?>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _ProjectPickerDialog(initialProjectId: initialProjectId),
  );
}

class _ProjectPickerDialog extends ConsumerStatefulWidget {
  const _ProjectPickerDialog({this.initialProjectId});

  final int? initialProjectId;

  @override
  ConsumerState<_ProjectPickerDialog> createState() => _ProjectPickerDialogState();
}

class _ProjectPickerDialogState extends ConsumerState<_ProjectPickerDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(allProjectsProvider);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Search projects',
                    hintStyle: AppTextStyles.bodyMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: projectsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (projects) {
                    final filtered = projects.where((p) {
                      if (_query.isEmpty) return true;
                      return p.title.toLowerCase().contains(_query.toLowerCase());
                    }).toList();

                    return ListView(
                      shrinkWrap: true,
                      children: [
                        _ProjectRow(
                          label: 'Inbox',
                          icon: Icons.inbox_outlined,
                          selected: widget.initialProjectId == null,
                          onTap: () => Navigator.of(context).pop(-1),
                        ),
                        ...filtered.map((p) => _ProjectRow(
                              label: p.title,
                              icon: Icons.folder_outlined,
                              selected: widget.initialProjectId == p.id,
                              onTap: () => Navigator.of(context).pop(p.id),
                            )),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectRow extends StatefulWidget {
  const _ProjectRow({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ProjectRow> createState() => _ProjectRowState();
}

class _ProjectRowState extends State<_ProjectRow> {
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
          color: widget.selected || _hovered
              ? AppColors.hoverBackground
              : Colors.transparent,
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: AppColors.muted),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(widget.label, style: AppTextStyles.itemTitle)),
              if (widget.selected)
                const Icon(Icons.check, size: 18, color: Color(0xFFE53935)),
            ],
          ),
        ),
      ),
    );
  }
}

enum LinkTaskResultType { createNew, existingTask }

class LinkTaskResult {
  const LinkTaskResult._({
    required this.type,
    this.title,
    this.existingTaskId,
  });

  final LinkTaskResultType type;
  final String? title;
  final int? existingTaskId;

  factory LinkTaskResult.createNew(String title) => LinkTaskResult._(
        type: LinkTaskResultType.createNew,
        title: title,
      );

  factory LinkTaskResult.existing(int taskId) => LinkTaskResult._(
        type: LinkTaskResultType.existingTask,
        existingTaskId: taskId,
      );
}

Future<LinkTaskResult?> showLinkTaskDialog(
  BuildContext context, {
  int? excludeTaskId,
}) {
  return showDialog<LinkTaskResult>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _LinkTaskDialog(excludeTaskId: excludeTaskId),
  );
}

class _LinkTaskDialog extends ConsumerStatefulWidget {
  const _LinkTaskDialog({this.excludeTaskId});

  final int? excludeTaskId;

  @override
  ConsumerState<_LinkTaskDialog> createState() => _LinkTaskDialogState();
}

class _LinkTaskDialogState extends ConsumerState<_LinkTaskDialog> {
  final _searchController = TextEditingController();
  final _newTaskController = TextEditingController();
  String _query = '';
  bool _showNewTask = false;

  @override
  void dispose() {
    _searchController.dispose();
    _newTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(inboxTasksProvider);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {
                    _query = value;
                    _showNewTask = value.isNotEmpty;
                  }),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search or create task',
                    hintStyle: AppTextStyles.bodyMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: _showNewTask
                    ? _buildCreateNewOption()
                    : tasksAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                        data: (tasks) {
                          final filtered = tasks
                              .where((t) =>
                                  t.id != widget.excludeTaskId &&
                                  t.title
                                      .toLowerCase()
                                      .contains(_query.toLowerCase()))
                              .toList();

                          return ListView(
                            shrinkWrap: true,
                            children: filtered
                                .map((t) => _TaskRow(
                                      title: t.title,
                                      onTap: () => Navigator.of(context)
                                          .pop(LinkTaskResult.existing(t.id)),
                                    ))
                                .toList(),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateNewOption() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create new task',
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _newTaskController..text = _query,
            decoration: InputDecoration(
              hintText: 'Task title',
              hintStyle: AppTextStyles.bodyMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_newTaskController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(
                    LinkTaskResult.createNew(_newTaskController.text.trim()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Create'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatefulWidget {
  const _TaskRow({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  State<_TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<_TaskRow> {
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
          color: _hovered ? AppColors.hoverBackground : Colors.transparent,
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: AppColors.muted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.title,
                  style: AppTextStyles.itemTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum LinkEventDeadlineType { event, deadline }

class LinkEventDeadlineResult {
  const LinkEventDeadlineResult._({this.itemId});

  final int? itemId;
}

Future<LinkEventDeadlineResult?> showLinkEventDeadlineDialog(
  BuildContext context, {
  required LinkEventDeadlineType type,
}) {
  return showDialog<LinkEventDeadlineResult>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _LinkEventDeadlineDialog(type: type),
  );
}

class _LinkEventDeadlineDialog extends ConsumerStatefulWidget {
  const _LinkEventDeadlineDialog({required this.type});

  final LinkEventDeadlineType type;

  @override
  ConsumerState<_LinkEventDeadlineDialog> createState() =>
      _LinkEventDeadlineDialogState();
}

class _LinkEventDeadlineDialogState
    extends ConsumerState<_LinkEventDeadlineDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(upcomingEventsProvider);
    final deadlinesAsync = ref.watch(activeDeadlinesProvider);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: widget.type == LinkEventDeadlineType.event
                        ? 'Search events'
                        : 'Search deadlines',
                    hintStyle: AppTextStyles.bodyMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: widget.type == LinkEventDeadlineType.event
                    ? eventsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                        data: (events) {
                          final filtered = events
                              .where((e) => e.item.title
                                  .toLowerCase()
                                  .contains(_query.toLowerCase()))
                              .toList();

                          return ListView(
                            shrinkWrap: true,
                            children: filtered
                                .map((e) => _TaskRow(
                                      title: e.item.title,
                                      onTap: () => Navigator.of(context).pop(
                                        LinkEventDeadlineResult._(itemId: e.item.id),
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                      )
                    : deadlinesAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                        data: (deadlines) {
                          final filtered = deadlines
                              .where((d) => d.item.title
                                  .toLowerCase()
                                  .contains(_query.toLowerCase()))
                              .toList();

                          return ListView(
                            shrinkWrap: true,
                            children: filtered
                                .map((d) => _TaskRow(
                                      title: d.item.title,
                                      onTap: () => Navigator.of(context).pop(
                                        LinkEventDeadlineResult._(
                                            itemId: d.item.id),
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}