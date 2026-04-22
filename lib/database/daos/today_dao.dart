import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/item_dates.dart';
import '../tables/items.dart';

part 'today_dao.g.dart';

class TodayItemWithDate {
  const TodayItemWithDate({required this.item, required this.itemDate});

  final Item item;
  final ItemDate itemDate;
}

@DriftAccessor(tables: [Items, ItemDates])
class TodayDao extends DatabaseAccessor<AppDatabase> with _$TodayDaoMixin {
  TodayDao(super.db);

  Stream<List<TodayItemWithDate>> watchTodayActiveItems(DateTime date) {
    return watchTodayItems(date, completed: false);
  }

  Stream<List<TodayItemWithDate>> watchTodayCompletedItems(DateTime date) {
    return watchTodayItems(date, completed: true);
  }

  Stream<List<TodayItemWithDate>> watchTodayItems(
    DateTime date, {
    required bool completed,
  }) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final nextDay = dayStart.add(const Duration(days: 1));

    final tasksToday =
        (items.itemType.equals('scheduled_task') |
            items.itemType.equals('unscheduled_task') |
            items.itemType.equals('deadline')) &
        itemDates.endDate.isBiggerOrEqualValue(dayStart) &
        itemDates.endDate.isSmallerThanValue(nextDay);

    final eventsToday =
        items.itemType.equals('event') &
        itemDates.startDate.isSmallerThanValue(nextDay) &
        itemDates.endDate.isBiggerOrEqualValue(dayStart);

    final query =
        select(
            items,
          ).join([innerJoin(itemDates, itemDates.itemId.equalsExp(items.id))])
          ..where(items.deletedAt.isNull())
          ..where(items.completed.equals(completed))
          ..where(tasksToday | eventsToday)
          ..orderBy([
            OrderingTerm.asc(itemDates.endDate),
            OrderingTerm.asc(itemDates.startDate),
            OrderingTerm.asc(items.createdAt),
          ]);

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => TodayItemWithDate(
              item: row.readTable(items),
              itemDate: row.readTable(itemDates),
            ),
          )
          .toList(),
    );
  }
}
