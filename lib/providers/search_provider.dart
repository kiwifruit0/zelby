import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/item.dart';
import '../models/recent_item.dart';
import '../models/search_command.dart';
import '../models/search_result.dart';
import '../providers/database_provider.dart';
import '../registry/navigation_registry.dart';

part 'search_provider.g.dart';

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

@riverpod
class SearchOverlayVisible extends _$SearchOverlayVisible {
  @override
  bool build() => false;

  void show() => state = true;
  void hide() => state = false;
  void toggle() => state = !state;
}

@riverpod
class IncludePastEvents extends _$IncludePastEvents {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}

@riverpod
Stream<List<RecentItem>> recentItems(Ref ref) {
  final dao = ref.watch(appDatabaseProvider).recentItemsDao;
  return dao.watchRecent(5).map((rows) => rows.map((r) => RecentItem(
    id: r.id,
    type: r.type == 'item' ? RecentItemType.item : RecentItemType.route,
    itemId: r.itemId,
    route: r.route,
    title: r.title,
    subtitle: r.subtitle,
    iconKind: r.iconKind,
    updatedAt: r.updatedAt,
  )).toList());
}

@riverpod
List<SearchCommand> searchCommands(Ref ref) {
  return NavigationRegistry.commands;
}

@riverpod
List<SearchCommand> filteredCommands(Ref ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final allCommands = ref.watch(searchCommandsProvider);
  
  if (query.isEmpty) {
    return allCommands.where((c) => c.isDefault).toList();
  }
  
  return allCommands.where((c) {
    return c.title.toLowerCase().contains(query) || 
           (c.subtitle?.toLowerCase().contains(query) ?? false) ||
           c.keywords.any((k) => k.toLowerCase().contains(query));
  }).toList();
}

@riverpod
Future<List<SearchResult>> searchResults(Ref ref) async {
  final query = ref.watch(searchQueryProvider);
  final includePast = ref.watch(includePastEventsProvider);
  
  if (query.isEmpty) return [];

  // Add a small delay for debouncing
  await Future.delayed(const Duration(milliseconds: 200));

  final searchDao = ref.watch(appDatabaseProvider).searchDao;
  final rows = await searchDao.searchItems(query, includePastEvents: includePast);

  final results = rows.map((row) {
    final item = Item.fromDb(row.item);
    final score = _calculateScore(item, query);
    
    return SearchResult(
      item: item,
      score: score,
      startDate: row.itemDate?.startDate,
      endDate: row.itemDate?.endDate,
      projectName: row.projectName,
    );
  }).toList();

  // Sort by score descending
  results.sort((a, b) => b.score.compareTo(a.score));

  return results;
}

double _calculateScore(Item item, String query) {
  final title = item.title.toLowerCase();
  final q = query.toLowerCase();
  
  double score = 0.0;
  
  if (title == q) {
    score = 1.0;
  } else if (title.startsWith(q)) {
    score = 0.8;
  } else if (title.contains(q)) {
    score = 0.5;
  }
  
  final notes = item.notes?.toLowerCase() ?? '';
  if (notes.contains(q)) {
    score = score > 0.2 ? score : 0.2;
  }
  
  return score;
}
