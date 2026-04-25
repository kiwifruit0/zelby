import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/item_dates.dart';
import '../tables/items.dart';
import '../tables/projects.dart';

part 'search_dao.g.dart';

class SearchResultRow {
  const SearchResultRow({
    required this.item,
    this.itemDate,
    this.projectName,
  });

  final Item item;
  final ItemDate? itemDate;
  final String? projectName;
}

@DriftAccessor(tables: [Items, ItemDates, ProjectItems])
class SearchDao extends DatabaseAccessor<AppDatabase> with _$SearchDaoMixin {
  SearchDao(super.db);

  Future<List<SearchResultRow>> searchItems(String query) async {
    if (query.isEmpty) return [];

    final projectAlias = alias(items, 'project_title_alias');
    
    final dbQuery = select(items).join([
      leftOuterJoin(itemDates, itemDates.itemId.equalsExp(items.id)),
      leftOuterJoin(projectItems, projectItems.itemId.equalsExp(items.id)),
      leftOuterJoin(projectAlias, projectAlias.id.equalsExp(projectItems.projectId)),
    ])
      ..where(items.deletedAt.isNull())
      ..where(items.title.contains(query) | items.notes.contains(query));

    final rows = await dbQuery.get();

    return rows.map((row) {
      return SearchResultRow(
        item: row.readTable(items),
        itemDate: row.readTableOrNull(itemDates),
        projectName: row.readTableOrNull(projectAlias)?.title,
      );
    }).toList();
  }
}
