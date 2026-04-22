import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/dependencies.dart';
import '../tables/item_dates.dart';
import '../tables/items.dart';

part 'events_dao.g.dart';

class EventWithDates {
  const EventWithDates({
    required this.item,
    required this.itemDate,
  });

  final Item item;
  final ItemDate itemDate;
}

@DriftAccessor(tables: [Items, ItemDates, TaskDependencies])
class EventsDao extends DatabaseAccessor<AppDatabase> with _$EventsDaoMixin {
  EventsDao(super.db);

  Stream<List<EventWithDates>> watchUpcomingEvents() {
    final now = DateTime.now();
    final query = select(items).join([
      innerJoin(itemDates, itemDates.itemId.equalsExp(items.id)),
    ])
      ..where(items.itemType.equals('event'))
      ..where(items.deletedAt.isNull())
      ..where(itemDates.startDate.isNotNull())
      ..where(itemDates.endDate.isNotNull())
      ..where(itemDates.endDate.isBiggerThanValue(now));

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => EventWithDates(
                  item: row.readTable(items),
                  itemDate: row.readTable(itemDates),
                ),
              )
              .toList(),
        );
  }

  Stream<List<EventWithDates>> watchEventsForDateRange(
    DateTime start,
    DateTime end, {
    bool includeCompleted = false,
  }) {
    final query = select(items).join([
      innerJoin(itemDates, itemDates.itemId.equalsExp(items.id)),
    ])
      ..where(items.itemType.equals('event'))
      ..where(items.deletedAt.isNull())
      ..where(includeCompleted ? const Constant(true) : items.completed.equals(false))
      ..where(itemDates.startDate.isNotNull())
      ..where(itemDates.endDate.isNotNull())
      ..where(itemDates.startDate.isSmallerOrEqualValue(end))
      ..where(itemDates.endDate.isBiggerOrEqualValue(start));

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => EventWithDates(
                  item: row.readTable(items),
                  itemDate: row.readTable(itemDates),
                ),
              )
              .toList(),
        );
  }

  Stream<List<EventWithDates>> watchEventsForDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final nextDay = dayStart.add(const Duration(days: 1));
    final query = select(items).join([
      innerJoin(itemDates, itemDates.itemId.equalsExp(items.id)),
    ])
      ..where(items.itemType.equals('event'))
      ..where(items.deletedAt.isNull())
      ..where(itemDates.startDate.isNotNull())
      ..where(itemDates.endDate.isNotNull())
      ..where(itemDates.startDate.isSmallerThanValue(nextDay))
      ..where(itemDates.endDate.isBiggerOrEqualValue(dayStart));

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => EventWithDates(
                  item: row.readTable(items),
                  itemDate: row.readTable(itemDates),
                ),
              )
              .toList(),
        );
  }

  Future<int> insertEvent(
    String title,
    DateTime startDate,
    DateTime endDate, {
    String? notes,
  }) {
    final now = DateTime.now();

    return transaction(() async {
      final itemId = await into(items).insert(
        ItemsCompanion.insert(
          title: title,
          notes: notes == null ? const Value.absent() : Value(notes),
          itemType: 'event',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await into(itemDates).insert(
        ItemDatesCompanion.insert(
          itemId: Value(itemId),
          startDate: Value(startDate),
          endDate: Value(endDate),
        ),
      );

      return itemId;
    });
  }

  Future<int> softDelete(int id) {
    final now = DateTime.now();

    return (update(items)..where((tbl) => tbl.id.equals(id))).write(
      ItemsCompanion(
        deletedAt: Value(now),
      ),
    );
  }

  Future<void> updateEvent(
    int id, {
    String? title,
    DateTime? startDate,
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

      if (startDate != null || endDate != null) {
        await (update(itemDates)..where((tbl) => tbl.itemId.equals(id))).write(
          ItemDatesCompanion(
            startDate: startDate == null
                ? const Value.absent()
                : Value(startDate),
            endDate: endDate == null ? const Value.absent() : Value(endDate),
          ),
        );
      }
    });
  }

  Future<int> autoCompleteExpiredEvents() {
    final now = DateTime.now();
    final expiredEventIds = selectOnly(itemDates)
      ..addColumns([itemDates.itemId])
      ..where(itemDates.endDate.isSmallerThanValue(now));

    return (update(items)
          ..where((tbl) => tbl.itemType.equals('event'))
          ..where((tbl) => tbl.completed.equals(false))
          ..where((tbl) => tbl.id.isInQuery(expiredEventIds)))
        .write(
      ItemsCompanion(
        completed: const Value(true),
        completedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<List<Item>> getEventsForTask(int taskId) async {
    final query = select(items).join([
      innerJoin(
        taskDependencies,
        taskDependencies.dependsOnId.equalsExp(items.id),
      ),
    ])
      ..where(taskDependencies.taskId.equals(taskId))
      ..where(items.itemType.equals('event'))
      ..where(items.deletedAt.isNull());

    final rows = await query.get();
    return rows.map((row) => row.readTable(items)).toList();
  }
}
