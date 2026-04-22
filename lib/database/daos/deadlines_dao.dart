import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/dependencies.dart';
import '../tables/item_dates.dart';
import '../tables/items.dart';

part 'deadlines_dao.g.dart';

class DeadlineWithDate {
  const DeadlineWithDate({
    required this.item,
    required this.itemDate,
  });

  final Item item;
  final ItemDate itemDate;
}

@DriftAccessor(tables: [Items, ItemDates, TaskDependencies])
class DeadlinesDao extends DatabaseAccessor<AppDatabase>
    with _$DeadlinesDaoMixin {
  DeadlinesDao(super.db);

  Stream<List<DeadlineWithDate>> watchActiveDeadlines() {
    final query = select(items).join([
      innerJoin(itemDates, itemDates.itemId.equalsExp(items.id)),
    ])
      ..where(items.itemType.equals('deadline'))
      ..where(items.deletedAt.isNull())
      ..where(items.completed.equals(false))
      ..where(itemDates.endDate.isNotNull())
      ..orderBy([OrderingTerm.asc(itemDates.endDate)]);

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => DeadlineWithDate(
                  item: row.readTable(items),
                  itemDate: row.readTable(itemDates),
                ),
              )
              .toList(),
        );
  }

  Stream<List<DeadlineWithDate>> watchDeadlinesForDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final nextDay = dayStart.add(const Duration(days: 1));
    final query = select(items).join([
      innerJoin(itemDates, itemDates.itemId.equalsExp(items.id)),
    ])
      ..where(items.itemType.equals('deadline'))
      ..where(items.deletedAt.isNull())
      ..where(items.completed.equals(false))
      ..where(itemDates.endDate.isBiggerOrEqualValue(dayStart))
      ..where(itemDates.endDate.isSmallerThanValue(nextDay));

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => DeadlineWithDate(
                  item: row.readTable(items),
                  itemDate: row.readTable(itemDates),
                ),
              )
              .toList(),
        );
  }

  Stream<List<DeadlineWithDate>> watchAllDeadlinesForDateRange(
    DateTime start,
    DateTime end, {
    bool includeCompleted = false,
  }) {
    final query = select(items).join([
      innerJoin(itemDates, itemDates.itemId.equalsExp(items.id)),
    ])
      ..where(items.itemType.equals('deadline'))
      ..where(items.deletedAt.isNull())
      ..where(includeCompleted ? const Constant(true) : items.completed.equals(false))
      ..where(itemDates.endDate.isBiggerOrEqualValue(start))
      ..where(itemDates.endDate.isSmallerThanValue(end));

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => DeadlineWithDate(
                  item: row.readTable(items),
                  itemDate: row.readTable(itemDates),
                ),
              )
              .toList(),
        );
  }

  Future<int> insertDeadline(
    String title,
    DateTime endDate, {
    String? notes,
  }) {
    final now = DateTime.now();

    return transaction(() async {
      final itemId = await into(items).insert(
        ItemsCompanion.insert(
          title: title,
          notes: notes == null ? const Value.absent() : Value(notes),
          itemType: 'deadline',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await into(itemDates).insert(
        ItemDatesCompanion.insert(
          itemId: Value(itemId),
          endDate: Value(endDate),
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

  Future<void> updateDeadline(
    int id, {
    String? title,
    DateTime? endDate,
    String? notes,
  }) {
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

      if (endDate != null) {
        await (update(itemDates)..where((tbl) => tbl.itemId.equals(id))).write(
          ItemDatesCompanion(
            endDate: Value(endDate),
          ),
        );
      }
    });
  }

  Future<int> autoCompleteExpiredDeadlines() {
    final now = DateTime.now();
    final expiredDeadlineIds = selectOnly(itemDates)
      ..addColumns([itemDates.itemId])
      ..where(itemDates.endDate.isSmallerThanValue(now));

    return (update(items)
          ..where((tbl) => tbl.itemType.equals('deadline'))
          ..where((tbl) => tbl.completed.equals(false))
          ..where((tbl) => tbl.id.isInQuery(expiredDeadlineIds)))
        .write(
      ItemsCompanion(
        completed: const Value(true),
        completedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<List<Item>> getDeadlinesForTask(int taskId) async {
    final query = select(items).join([
      innerJoin(
        taskDependencies,
        taskDependencies.dependsOnId.equalsExp(items.id),
      ),
    ])
      ..where(taskDependencies.taskId.equals(taskId))
      ..where(items.itemType.equals('deadline'))
      ..where(items.deletedAt.isNull());

    final rows = await query.get();
    return rows.map((row) => row.readTable(items)).toList();
  }
}
