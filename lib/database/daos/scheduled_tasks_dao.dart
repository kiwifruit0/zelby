import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/item_dates.dart';
import '../tables/items.dart';

part 'scheduled_tasks_dao.g.dart';

class ScheduledTaskWithDate {
  const ScheduledTaskWithDate({
    required this.item,
    required this.itemDate,
  });

  final Item item;
  final ItemDate itemDate;
}

@DriftAccessor(tables: [Items, ItemDates])
class ScheduledTasksDao extends DatabaseAccessor<AppDatabase>
    with _$ScheduledTasksDaoMixin {
  ScheduledTasksDao(super.db);

  Stream<List<ScheduledTaskWithDate>> watchTasksForDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final nextDay = dayStart.add(const Duration(days: 1));

    final query = select(items).join([
      innerJoin(itemDates, itemDates.itemId.equalsExp(items.id)),
    ])
      ..where(items.itemType.equals('scheduled_task'))
      ..where(items.deletedAt.isNull())
      ..where(items.completed.equals(false))
      ..where(itemDates.endDate.isBiggerOrEqualValue(dayStart))
      ..where(itemDates.endDate.isSmallerThanValue(nextDay));

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => ScheduledTaskWithDate(
                  item: row.readTable(items),
                  itemDate: row.readTable(itemDates),
                ),
              )
              .toList(),
        );
  }

  Stream<List<ScheduledTaskWithDate>> watchTasksForDateRange(
    DateTime start,
    DateTime end,
  ) {
    final query = select(items).join([
      innerJoin(itemDates, itemDates.itemId.equalsExp(items.id)),
    ])
      ..where(items.itemType.equals('scheduled_task'))
      ..where(items.deletedAt.isNull())
      ..where(items.completed.equals(false))
      ..where(itemDates.endDate.isBiggerOrEqualValue(start))
      ..where(itemDates.endDate.isSmallerThanValue(end));

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => ScheduledTaskWithDate(
                  item: row.readTable(items),
                  itemDate: row.readTable(itemDates),
                ),
              )
              .toList(),
        );
  }

  Future<int> insertScheduledTask(String title, DateTime date, {String? notes}) {
    final now = DateTime.now();

    return transaction(() async {
      final itemId = await into(items).insert(
        ItemsCompanion.insert(
          title: title,
          notes: notes == null ? const Value.absent() : Value(notes),
          itemType: 'scheduled_task',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await into(itemDates).insert(
        ItemDatesCompanion.insert(
          itemId: Value(itemId),
          endDate: Value(date),
        ),
      );

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

  Future<void> updateTask(int id, {String? title, DateTime? date, String? notes}) {
    final now = DateTime.now();
    var itemUpdate = ItemsCompanion(
      updatedAt: Value(now),
    );

    if (title != null) {
      itemUpdate = itemUpdate.copyWith(title: Value(title));
    }

    if (notes != null) {
      itemUpdate = itemUpdate.copyWith(notes: Value(notes));
    }

    return transaction(() async {
      await (update(items)..where((tbl) => tbl.id.equals(id))).write(itemUpdate);

      if (date != null) {
        await (update(itemDates)..where((tbl) => tbl.itemId.equals(id))).write(
          ItemDatesCompanion(
            endDate: Value(date),
          ),
        );
      }
    });
  }
}
