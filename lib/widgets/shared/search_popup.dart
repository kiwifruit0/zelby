import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/item.dart';
import '../../models/search_result.dart';
import '../../providers/search_provider.dart';
import '../../theme/app_theme.dart';

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
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onKeyDown(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final results = ref.read(searchResultsProvider).value ?? [];
    if (results.isEmpty) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % results.length;
      });
      _scrollToIndex(_selectedIndex);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1 + results.length) % results.length;
      });
      _scrollToIndex(_selectedIndex);
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      _navigateTo(results[_selectedIndex]);
    }
  }

  void _scrollToIndex(int index) {
    // Basic scroll into view logic
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

  void _navigateTo(SearchResult result) {
    ref.read(searchOverlayVisibleProvider.notifier).hide();
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
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider);
    final visible = ref.watch(searchOverlayVisibleProvider);

    if (!visible) return const SizedBox.shrink();

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _onKeyDown,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: () => ref.read(searchOverlayVisibleProvider.notifier).hide(),
            child: Container(
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ),
          
          // Popup
          Align(
            alignment: const Alignment(0, -0.7),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 650,
                maxHeight: 500,
                minHeight: 100, // Ensure minimum height to prevent collapse
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                elevation: 10,
                clipBehavior: Clip.antiAlias,
                child: Container(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search Input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                  hintText: 'Search tasks, events, deadlines, and projects...',
                                  hintStyle: TextStyle(color: AppColors.muted, fontSize: 16),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 16, color: AppColors.primary),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.hoverBackground,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'ESC',
                                style: TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.divider),
                      
                      // Results
                      Flexible(
                        child: resultsAsync.when(
                          loading: () => const SizedBox(
                            height: 100,
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          error: (e, _) => Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text('Error: $e', style: AppTextStyles.bodyMuted),
                          ),
                          data: (results) {
                            if (results.isEmpty && _searchController.text.isNotEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.search_off, size: 48, color: AppColors.divider),
                                      SizedBox(height: 12),
                                      Text('No results found', style: AppTextStyles.bodyMuted),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            if (results.isEmpty) {
                              return const SizedBox(
                                height: 100,
                                child: Center(
                                  child: Text(
                                    'Type to search...',
                                    style: AppTextStyles.bodyMuted,
                                  ),
                                ),
                              );
                            }

                            // Grouping logic
                            final grouped = _groupResults(results);

                            return ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: grouped.length,
                              itemBuilder: (context, index) {
                                final item = grouped[index];
                                if (item is String) {
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                                    child: Text(
                                      item.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  );
                                } else {
                                  final result = item as SearchResult;
                                  final resultIndex = results.indexOf(result);
                                  final isSelected = resultIndex == _selectedIndex;
                                  
                                  return _SearchResultRow(
                                    result: result,
                                    isSelected: isSelected,
                                    onHover: () => setState(() => _selectedIndex = resultIndex),
                                    onTap: () => _navigateTo(result),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Object> _groupResults(List<SearchResult> results) {
    final groups = <String, List<SearchResult>>{};
    for (final r in results) {
      final type = _getDisplayType(r.item.itemType);
      groups.putIfAbsent(type, () => []).add(r);
    }

    final flatList = <Object>[];
    // Order: Tasks, Events, Deadlines, Projects
    final order = ['Tasks', 'Events', 'Deadlines', 'Projects'];
    for (final type in order) {
      if (groups.containsKey(type)) {
        flatList.add(type);
        flatList.addAll(groups[type]!);
      }
    }
    
    // Add any other types if they exist
    for (final type in groups.keys) {
      if (!order.contains(type)) {
        flatList.add(type);
        flatList.addAll(groups[type]!);
      }
    }

    return flatList;
  }

  String _getDisplayType(String type) {
    switch (type) {
      case 'unscheduled_task':
      case 'scheduled_task':
        return 'Tasks';
      case 'event':
        return 'Events';
      case 'deadline':
        return 'Deadlines';
      case 'project':
        return 'Projects';
      default:
        return 'Other';
    }
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({
    required this.result,
    required this.isSelected,
    required this.onHover,
    required this.onTap,
  });

  final SearchResult result;
  final bool isSelected;
  final VoidCallback onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = result.item;
    
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
              _buildIcon(item),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.itemTitle.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    if (result.projectName != null || result.endDate != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (result.projectName != null) ...[
                            Text(
                              '# ${result.projectName}',
                              style: AppTextStyles.itemMeta.copyWith(color: AppColors.accent),
                            ),
                            if (result.endDate != null)
                              const Text(' • ', style: AppTextStyles.itemMeta),
                          ],
                          if (result.endDate != null)
                            Text(
                              _formatDate(result.endDate!),
                              style: AppTextStyles.itemMeta,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.month}/${dt.day}/${dt.year.toString().substring(2)}';

  Widget _buildIcon(Item item) {
    switch (item.itemType) {
      case 'unscheduled_task':
      case 'scheduled_task':
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.muted, width: 1.5),
          ),
          child: item.itemType == 'scheduled_task' 
            ? const Icon(Icons.access_time, size: 10, color: AppColors.muted)
            : null,
        );
      case 'event':
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.muted, width: 1.5),
          ),
        );
      case 'deadline':
        return Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF43A047), width: 1.5),
          ),
        );
      case 'project':
        return const Icon(Icons.folder_outlined, size: 18, color: AppColors.muted);
      default:
        return const Icon(Icons.circle, size: 18, color: AppColors.muted);
    }
  }
}
