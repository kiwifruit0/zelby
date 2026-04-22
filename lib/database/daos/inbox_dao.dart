import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/item_dates.dart';
import '../tables/items.dart';

part 'inbox_dao.g.dart';

@DriftAccessor(tables: [Items, ItemDates])
class InboxDao extends DatabaseAccessor<AppDatabase> with _$InboxDaoMixin {
  InboxDao(super.db);

  Stream<List<Item>> watchInboxTasks() {
    return (select(items)
          ..where(
            (tbl) =>
                tbl.itemType.equals('unscheduled_task') &
                tbl.deletedAt.isNull() &
                tbl.completed.equals(false),
          ))
        .watch();
  }

  Future<List<Item>> getInboxTasks() {
    return (select(items)
          ..where(
            (tbl) =>
                tbl.itemType.equals('unscheduled_task') &
                tbl.deletedAt.isNull() &
                tbl.completed.equals(false),
          ))
        .get();
  }

  Future<int> insertTask(
    String title, {
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();

    return transaction(() async {
      final itemId = await into(items).insert(
        ItemsCompanion.insert(
          title: title,
          notes: notes == null ? const Value.absent() : Value(notes),
          itemType: 'unscheduled_task',
          createdAt: now,
          updatedAt: now,
        ),
      );

      if (startDate != null || endDate != null) {
        await into(itemDates).insert(
          ItemDatesCompanion.insert(
            itemId: Value(itemId),
            startDate:
                startDate == null ? const Value.absent() : Value(startDate),
            endDate: endDate == null ? const Value.absent() : Value(endDate),
          ),
        );
      }

      return itemId;
    });
  }

  Future<int> markComplete(int id) {
    final now = DateTime.now();

    return (update(items)..where((tbl) => tbl.id.equals(id))).write(
      ItemsCompanion(
        completed: const Value(true),
        completedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> softDelete(int id) {
    final now = DateTime.now();

    return (update(items)..where((tbl) => tbl.id.equals(id))).write(
      ItemsCompanion(
        deletedAt: Value(now),
      ),
    );
  }

  Future<int> updateTask(int id, {String? title, String? notes}) {
    final now = DateTime.now();
    var companion = ItemsCompanion(
      updatedAt: Value(now),
    );

    if (title != null) {
      companion = companion.copyWith(title: Value(title));
    }

    if (notes != null) {
      companion = companion.copyWith(notes: Value(notes));
    }

    return (update(items)..where((tbl) => tbl.id.equals(id))).write(companion);
  }
}
