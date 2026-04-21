import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/database_provider.dart';
import '../../providers/deadlines_provider.dart';
import '../../theme/app_theme.dart';

class DeadlinesScreen extends ConsumerStatefulWidget {
  const DeadlinesScreen({super.key});

  @override
  ConsumerState<DeadlinesScreen> createState() => _DeadlinesScreenState();
}

class _DeadlinesScreenState extends ConsumerState<DeadlinesScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(appDatabaseProvider).deadlinesDao.autoCompleteExpiredDeadlines();
  }

  @override
  Widget build(BuildContext context) {
    final deadlinesAsync = ref.watch(activeDeadlinesProvider);

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
          child: Text('Deadlines', style: AppTextStyles.pageTitle),
        ),
        Expanded(
          child: deadlinesAsync.when(
            loading: () => const _ShimmerList(),
            error: (e, _) => Center(
              child: Text(
                'Something went wrong: $e',
                style: AppTextStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
            ),
            data: (deadlines) => _DeadlineList(deadlines: deadlines),
          ),
        ),
      ],
    );
  }
}

// ── Urgency helpers ──────────────────────────────────────────────────────────

Color _urgencyColor(DateTime? endDate) {
  if (endDate == null) return AppColors.muted;
  final days = endDate.difference(DateTime.now()).inDays;
  if (days < 3) return const Color(0xFFE53935); // red — < 3 days or overdue
  if (days < 7) return const Color(0xFFFB8C00); // amber — 3–7 days
  return const Color(0xFF43A047); // green — > 7 days
}

String _formatDate(DateTime dt) =>
    '${dt.month}/${dt.day}/${dt.year.toString().substring(2)}';

// ── Deadline list ────────────────────────────────────────────────────────────

class _DeadlineList extends ConsumerStatefulWidget {
  const _DeadlineList({required this.deadlines});

  final List<DeadlineWithDate> deadlines;

  @override
  ConsumerState<_DeadlineList> createState() => _DeadlineListState();
}

class _DeadlineListState extends ConsumerState<_DeadlineList> {
  int? _hoveredId;

  Future<void> _insert(String title, DateTime date) async {
    await ref
        .read(appDatabaseProvider)
        .deadlinesDao
        .insertDeadline(title, date);
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
          if (index == 0) return const _EmptyState();
          return _CaptureRow(onSubmit: _insert);
        }

        if (index == deadlines.length) {
          return _CaptureRow(onSubmit: _insert);
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

// ── Individual deadline row ──────────────────────────────────────────────────

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
    final dateLabel = deadline.endDate != null
        ? _formatDate(deadline.endDate!)
        : '—';

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

// ── Capture row ──────────────────────────────────────────────────────────────

class _CaptureRow extends StatefulWidget {
  const _CaptureRow({required this.onSubmit});

  final void Function(String title, DateTime date) onSubmit;

  @override
  State<_CaptureRow> createState() => _CaptureRowState();
}

class _CaptureRowState extends State<_CaptureRow> {
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
        child: Text('No active deadlines', style: AppTextStyles.bodyMuted),
      ),
    );
  }
}

// ── Shimmer placeholders ─────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
