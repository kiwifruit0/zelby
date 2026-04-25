import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/recent_item.dart';
import '../../models/search_command.dart';
import '../../models/search_filter_chip.dart';
import '../../models/search_result.dart';
import '../../providers/database_provider.dart';
import '../../providers/search_provider.dart';
import '../../theme/app_theme.dart';
import 'filter_chip_row.dart';

class SearchPopup extends ConsumerStatefulWidget {
  const SearchPopup({super.key});

  @override
  ConsumerState<SearchPopup> createState() => _SearchPopupState();
}

class _SearchPopupState extends ConsumerState<SearchPopup> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  int _selectedIndex = 0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Request focus on next frame to ensure widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onKeyDown(KeyEvent event, List<Object> groupedItems) {
    if (event is! KeyDownEvent) return;

    // Refocus if typing and not focused
    if (!_focusNode.hasFocus && 
        event.character != null && 
        event.logicalKey != LogicalKeyboardKey.escape &&
        event.logicalKey != LogicalKeyboardKey.enter &&
        event.logicalKey != LogicalKeyboardKey.arrowDown &&
        event.logicalKey != LogicalKeyboardKey.arrowUp) {
      _focusNode.requestFocus();
    }

    // Filter out section headers for keyboard navigation
    final selectableItems = groupedItems.where((i) => i is! String).toList();
    if (selectableItems.isEmpty) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % selectableItems.length;
      });
      _scrollToIndex(_selectedIndex);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1 + selectableItems.length) % selectableItems.length;
      });
      _scrollToIndex(_selectedIndex);
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      _navigateTo(selectableItems[_selectedIndex]);
    }
  }

  void _scrollToIndex(int index) {
    const itemHeight = 56.0;
    final offset = index * itemHeight;
    if (offset < _scrollController.offset) {
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    } else if (offset > _scrollController.offset + 400 - itemHeight) {
      _scrollController.animateTo(
        offset - 400 + itemHeight,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _navigateTo(dynamic result) async {
    final db = ref.read(appDatabaseProvider);
    final dao = db.recentItemsDao;
    
    if (result is SearchCommand) {
      await dao.recordView(
        type: 'route',
        route: result.route,
        title: result.title,
        iconKind: 'command',
      );
    } else if (result is SearchResult) {
      await dao.recordView(
        type: 'item',
        itemId: result.item.id,
        title: result.item.title,
        subtitle: result.projectName,
        iconKind: result.item.itemType,
      );
    } else if (result is RecentItem) {
      await dao.recordView(
        type: result.type == RecentItemType.item ? 'item' : 'route',
        itemId: result.itemId,
        route: result.route,
        title: result.title,
        subtitle: result.subtitle,
        iconKind: result.iconKind,
      );
    }

    if (!mounted) return;
    ref.read(searchOverlayVisibleProvider.notifier).hide();

    if (result is SearchCommand) {
      if (result.onTap != null) {
        result.onTap!();
      } else if (result.route != null) {
        context.go(result.route!);
      }
    } else if (result is SearchResult) {
      final item = result.item;
      if (item.itemType == 'project') {
        context.go('/projects/${item.id}');
      } else if (item.itemType == 'unscheduled_task') {
        context.go('/inbox');
      } else if (item.itemType == 'scheduled_task') {
        context.go('/upcoming');
      } else if (item.itemType == 'event' || item.itemType == 'deadline') {
        context.go('/events-deadlines');
      }
    } else if (result is RecentItem) {
      if (result.type == RecentItemType.route && result.route != null) {
        context.go(result.route!);
      } else if (result.type == RecentItemType.item && result.itemId != null) {
        if (result.iconKind == 'project') {
          context.go('/projects/${result.itemId}');
        } else if (result.iconKind == 'unscheduled_task') {
          context.go('/inbox');
        } else if (result.iconKind == 'scheduled_task') {
          context.go('/upcoming');
        } else {
          context.go('/events-deadlines');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final includePast = ref.watch(includePastEventsProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final commands = ref.watch(filteredCommandsProvider);
    final recentAsync = ref.watch(recentItemsProvider);
    final visible = ref.watch(searchOverlayVisibleProvider);

    if (!visible) return const SizedBox.shrink();

    final results = resultsAsync.value ?? [];
    final recent = recentAsync.value ?? [];
    final grouped = _groupResults(query, recent, commands, results);
    final selectableItems = grouped.where((i) => i is! String).toList();

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (e) => _onKeyDown(e, grouped),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => ref.read(searchOverlayVisibleProvider.notifier).hide(),
            child: Container(color: Colors.black.withValues(alpha: 0.1)),
          ),
          Align(
            alignment: const Alignment(0, -0.7),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 650,
                maxHeight: 500,
                minHeight: 100,
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                elevation: 10,
                clipBehavior: Clip.antiAlias,
                child: GestureDetector(
                  onTap: () => _focusNode.requestFocus(), // Fix (1): Refocus on click
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchInput(query),
                        FilterChipRow(chips: _buildFilterChips(includePast)),
                        const Divider(height: 1, color: AppColors.divider),
                        _buildResultsArea(resultsAsync, grouped, selectableItems),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput(String query) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.muted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).updateQuery(val);
                setState(() => _selectedIndex = 0);
              },
              decoration: const InputDecoration(
                hintText: 'Search items or commands...',
                hintStyle: TextStyle(color: AppColors.muted, fontSize: 16),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 16, color: AppColors.primary),
            ),
          ),
          _buildShortcutHint('ESC'),
        ],
      ),
    );
  }

  List<SearchFilterChip> _buildFilterChips(bool includePast) {
    return [
      SearchFilterChip(
        id: 'include_past_events',
        label: 'Include past events',
        isSelected: includePast,
        onTap: () {
          ref.read(includePastEventsProvider.notifier).toggle();
          _focusNode.requestFocus();
        },
      ),
    ];
  }

  Widget _buildShortcutHint(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.hoverBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildResultsArea(AsyncValue resultsAsync, List<Object> grouped, List<Object> selectableItems) {
    return Flexible(
      child: resultsAsync.when(
        loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        error: (e, _) => Padding(padding: const EdgeInsets.all(20.0), child: Text('Error: $e', style: AppTextStyles.bodyMuted)),
        data: (_) {
          if (grouped.isEmpty) {
            return const SizedBox(height: 100, child: Center(child: Text('No results found', style: AppTextStyles.bodyMuted)));
          }

          return ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final item = grouped[index];
              if (item is String) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: Text(item.toUpperCase(), style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                );
              } else {
                final isSelected = selectableItems.indexOf(item) == _selectedIndex;
                return _UnifiedResultRow(
                  item: item,
                  isSelected: isSelected,
                  onHover: () => setState(() => _selectedIndex = selectableItems.indexOf(item)),
                  onTap: () => _navigateTo(item),
                );
              }
            },
          );
        },
      ),
    );
  }

  List<Object> _groupResults(String query, List<RecentItem> recent, List<SearchCommand> commands, List<SearchResult> results) {
    final grouped = <Object>[];
    
    if (query.isEmpty) {
      if (recent.isNotEmpty) {
        grouped.add('Recently viewed');
        grouped.addAll(recent);
      }
      if (commands.isNotEmpty) {
        grouped.add('Navigation');
        grouped.addAll(commands);
      }
    } else {
      if (commands.isNotEmpty) {
        grouped.add('Navigation');
        grouped.addAll(commands);
      }
      
      final resultGroups = <String, List<SearchResult>>{};
      for (final r in results) {
        final type = _getDisplayType(r.item.itemType);
        resultGroups.putIfAbsent(type, () => []).add(r);
      }

      final order = ['Tasks', 'Events', 'Deadlines', 'Projects'];
      for (final type in order) {
        if (resultGroups.containsKey(type)) {
          grouped.add(type);
          grouped.addAll(resultGroups[type]!);
        }
      }
    }
    return grouped;
  }

  String _getDisplayType(String type) {
    switch (type) {
      case 'unscheduled_task':
      case 'scheduled_task': return 'Tasks';
      case 'event': return 'Events';
      case 'deadline': return 'Deadlines';
      case 'project': return 'Projects';
      default: return 'Other';
    }
  }
}

class _UnifiedResultRow extends StatelessWidget {
  const _UnifiedResultRow({
    required this.item,
    required this.isSelected,
    required this.onHover,
    required this.onTap,
  });

  final Object item;
  final bool isSelected;
  final VoidCallback onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String title = '';
    String? subtitle;
    Widget? icon;

    if (item is SearchCommand) {
      final cmd = item as SearchCommand;
      title = cmd.title;
      subtitle = cmd.subtitle;
      icon = Icon(cmd.icon, size: 18, color: AppColors.muted);
    } else if (item is SearchResult) {
      final res = item as SearchResult;
      title = res.item.title;
      subtitle = res.projectName;
      icon = _buildIcon(res.item.itemType);
    } else if (item is RecentItem) {
      final rec = item as RecentItem;
      title = rec.title;
      subtitle = rec.subtitle;
      icon = rec.type == RecentItemType.route 
          ? const Icon(Icons.history, size: 18, color: AppColors.muted)
          : _buildIcon(rec.iconKind);
    }

    return MouseRegion(
      onEnter: (_) => onHover(),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isSelected ? AppColors.hoverBackground : Colors.transparent,
          child: Row(
            children: [
              icon ?? const SizedBox(width: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.itemTitle.copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                    if (subtitle != null) Text(subtitle, style: AppTextStyles.itemMeta),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.keyboard_return, size: 14, color: AppColors.divider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String type) {
    switch (type) {
      case 'unscheduled_task':
      case 'scheduled_task':
        return Container(
          width: 18, height: 18,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.muted, width: 1.5)),
          child: type == 'scheduled_task' ? const Icon(Icons.access_time, size: 10, color: AppColors.muted) : null,
        );
      case 'event':
        return Container(
          width: 18, height: 18,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.muted, width: 1.5)),
        );
      case 'deadline':
        return Container(
          width: 18, height: 18,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF43A047), width: 1.5)),
        );
      case 'project':
        return const Icon(Icons.folder_outlined, size: 18, color: AppColors.muted);
      default:
        return const Icon(Icons.circle, size: 18, color: AppColors.muted);
    }
  }
}
