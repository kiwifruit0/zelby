import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/recent_items.dart';

part 'recent_items_dao.g.dart';

@DriftAccessor(tables: [RecentItems])
class RecentItemsDao extends DatabaseAccessor<AppDatabase> with _$RecentItemsDaoMixin {
  RecentItemsDao(super.db);

  Stream<List<RecentItem>> watchRecent(int limit) {
    return (select(recentItems)
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)])
          ..limit(limit))
        .watch();
  }

  Future<void> recordView({
    required String type,
    int? itemId,
    String? route,
    required String title,
    String? subtitle,
    required String iconKind,
  }) async {
    final existing = await (select(recentItems)
          ..where((t) => type == 'item' 
              ? t.itemId.equals(itemId!) 
              : t.route.equals(route!)))
        .getSingleOrNull();

    if (existing != null) {
      await (update(recentItems)..where((t) => t.id.equals(existing.id))).write(
        RecentItemsCompanion(
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      await into(recentItems).insert(
        RecentItemsCompanion.insert(
          type: type,
          itemId: Value(itemId),
          route: Value(route),
          title: title,
          subtitle: Value(subtitle),
          iconKind: iconKind,
          updatedAt: DateTime.now(),
        ),
      );
      
      final countQuery = countAll();
      final count = await (selectOnly(recentItems)..addColumns([countQuery]))
          .map((row) => row.read(countQuery))
          .getSingle();
      
      if (count != null && count > 20) {
        final oldest = await (select(recentItems)
              ..orderBy([(t) => OrderingTerm(expression: t.updatedAt)])
              ..limit(1))
            .getSingle();
        await (delete(recentItems)..where((t) => t.id.equals(oldest.id))).go();
      }
    }
  }
}
