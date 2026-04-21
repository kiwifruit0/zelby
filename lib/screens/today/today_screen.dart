import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/database_provider.dart';
import '../../providers/today_provider.dart';
import '../../theme/app_theme.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  @override
  void initState() {
    super.initState();
    // Keep completed grouping accurate when opening Today.
    final db = ref.read(appDatabaseProvider);
    db.eventsDao.autoCompleteExpiredEvents();
    db.deadlinesDao.autoCompleteExpiredDeadlines();
  }

  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(todayActiveItemsProvider);
    final completedAsync = ref.watch(todayCompletedItemsProvider);

    return activeAsync.when(
      loading: () => const _ShimmerList(),
      error: (e, _) => Center(
        child: Text(
          'Something went wrong: $e',
          style: AppTextStyles.bodyMuted,
          textAlign: TextAlign.center,
        ),
      ),
      data: (activeItems) => completedAsync.when(
        loading: () => const _ShimmerList(),
        error: (e, _) => Center(
          child: Text(
            'Something went wrong: $e',
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ),
        data: (completedItems) => _TodayContent(
          activeItems: activeItems,
          completedItems: completedItems,
        ),
      ),
    );
  }
}

class _TodayContent extends ConsumerStatefulWidget {
  const _TodayContent({
    required this.activeItems,
    required this.completedItems,
  });

  final List<TodayItem> activeItems;
  final List<TodayItem> completedItems;

  @override
  ConsumerState<_TodayContent> createState() => _TodayContentState();
}

class _TodayContentState extends ConsumerState<_TodayContent> {
  int? _hoveredActiveId;
  int? _hoveredCompletedId;

  Future<void> _markComplete(TodayItem item) async {
    final db = ref.read(appDatabaseProvider);
    if (item.isScheduledTask) {
      await db.scheduledTasksDao.markComplete(item.item.id);
      return;
    }
    if (item.isDeadline) {
      await db.deadlinesDao.markComplete(item.item.id);
    }
  }

  Future<void> _insertInboxTask(String title) async {
    await ref.read(appDatabaseProvider).inboxDao.insertTask(title);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.activeItems;
    final completed = widget.completedItems;
    final countLabel =
        '${active.length} ${active.length == 1 ? 'task' : 'tasks'}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      children: [
        const Text('Today', style: AppTextStyles.pageTitle),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 24,
              color: AppColors.muted,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              countLabel,
              style: AppTextStyles.body.copyWith(color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (active.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text('No tasks for today', style: AppTextStyles.bodyMuted),
          )
        else
          ...active.map(
            (item) => _TodayActiveRow(
              item: item,
              hovered: _hoveredActiveId == item.item.id,
              onHoverChanged: (on) =>
                  setState(() => _hoveredActiveId = on ? item.item.id : null),
              onComplete: item.isEvent ? null : () => _markComplete(item),
            ),
          ),
        const Divider(height: 1, thickness: 1, color: AppColors.divider),
        _InlineAddTask(onSubmit: _insertInboxTask),
        if (completed.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Completed',
            style: AppTextStyles.sectionHeader.copyWith(
              color: AppColors.muted,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...completed.map(
            (item) => _TodayCompletedRow(
              item: item,
              hovered: _hoveredCompletedId == item.item.id,
              onHoverChanged: (on) => setState(
                () => _hoveredCompletedId = on ? item.item.id : null,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TodayActiveRow extends StatelessWidget {
  const _TodayActiveRow({
    required this.item,
    required this.hovered,
    required this.onHoverChanged,
    required this.onComplete,
  });

  final TodayItem item;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: hovered ? AppColors.hoverBackground : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LeadingCompletionIcon(item: item, onTap: onComplete),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.item.title, style: AppTextStyles.itemTitle),
                    if (item.item.notes != null && item.item.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.item.notes!,
                          style: AppTextStyles.bodyMuted,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _MetadataLine(item: item),
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

class _TodayCompletedRow extends StatelessWidget {
  const _TodayCompletedRow({
    required this.item,
    required this.hovered,
    required this.onHoverChanged,
  });

  final TodayItem item;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: hovered ? AppColors.hoverBackground : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, size: 22, color: AppColors.muted),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  item.item.title,
                  style: AppTextStyles.bodyMuted.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.muted,
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

class _LeadingCompletionIcon extends StatelessWidget {
  const _LeadingCompletionIcon({required this.item, required this.onTap});

  final TodayItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (item.isEvent) {
      return Tooltip(
        message: 'Events complete automatically',
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.muted, width: 1.5),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.muted, width: 1.5),
        ),
      ),
    );
  }
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({required this.item});

  final TodayItem item;

  static const _metaGreen = Color(0xFF1E8E3E);

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

  String _label() {
    if (item.isEvent) {
      final start = _formatTime(item.startDate);
      final end = _formatTime(item.endDate);
      if (start.isEmpty && end.isEmpty) return '';
      if (end.isEmpty) return start;
      if (start.isEmpty) return end;
      return '$start - $end';
    }
    return _formatTime(item.endDate);
  }

  @override
  Widget build(BuildContext context) {
    final label = _label();
    if (label.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        const Icon(Icons.calendar_today_outlined, size: 14, color: _metaGreen),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.itemMeta.copyWith(color: _metaGreen)),
      ],
    );
  }
}

class _InlineAddTask extends StatefulWidget {
  const _InlineAddTask({required this.onSubmit});

  final Future<void> Function(String title) onSubmit;

  @override
  State<_InlineAddTask> createState() => _InlineAddTaskState();
}

class _InlineAddTaskState extends State<_InlineAddTask> {
  bool _expanded = false;
  bool _hovered = false;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() => _expanded = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  Future<void> _submit() async {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      await widget.onSubmit(title);
    }
    if (!mounted) return;
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
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _expand,
          child: Container(
            color: _hovered ? AppColors.hoverBackground : Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                const Text(
                  '+',
                  style: TextStyle(color: Colors.red, fontSize: 16, height: 1),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Add task',
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          const SizedBox(width: 4),
          const Icon(Icons.circle_outlined, size: 20, color: AppColors.muted),
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
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
      ),
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
