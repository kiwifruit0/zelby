import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/search_result.dart';
import '../providers/database_provider.dart';
import '../providers/inbox_provider.dart';

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
Future<List<SearchResult>> searchResults(Ref ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  // Add a small delay for debouncing
  await Future.delayed(const Duration(milliseconds: 200));

  final searchDao = ref.watch(appDatabaseProvider).searchDao;
  final rows = await searchDao.searchItems(query);

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
