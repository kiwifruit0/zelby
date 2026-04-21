import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/daos/deadlines_dao.dart' as deadlines_dao;
import '../database/daos/events_dao.dart' as events_dao;
import '../database/daos/scheduled_tasks_dao.dart' as scheduled_tasks_dao;
import 'database_provider.dart';
import 'inbox_provider.dart';

part 'schedule_provider.g.dart';

enum ScheduleItemType {
  scheduledTask,
  event,
  deadline,
}

class ScheduleItem {
  const ScheduleItem({
    required this.item,
    required this.itemType,
    required this.startDate,
    required this.endDate,
  });

  factory ScheduleItem.fromScheduledTask(scheduled_tasks_dao.ScheduledTaskWithDate value) {
    return ScheduleItem(
      item: Item.fromDb(value.item),
      itemType: ScheduleItemType.scheduledTask,
      startDate: value.itemDate.startDate,
      endDate: value.itemDate.endDate,
    );
  }

  factory ScheduleItem.fromEvent(events_dao.EventWithDates value) {
    return ScheduleItem(
      item: Item.fromDb(value.item),
      itemType: ScheduleItemType.event,
      startDate: value.itemDate.startDate,
      endDate: value.itemDate.endDate,
    );
  }

  factory ScheduleItem.fromDeadline(deadlines_dao.DeadlineWithDate value) {
    return ScheduleItem(
      item: Item.fromDb(value.item),
      itemType: ScheduleItemType.deadline,
      startDate: null,
      endDate: value.itemDate.endDate,
    );
  }

  final Item item;
  final ScheduleItemType itemType;
  final DateTime? startDate;
  final DateTime? endDate;

  bool get isCompleted => item.completed;
}

class ScheduleDay {
  const ScheduleDay({
    required this.date,
    required this.items,
  });

  final DateTime date;
  final List<ScheduleItem> items;

  bool get hasItems => items.isNotEmpty;
}

@riverpod
Stream<List<ScheduleDay>> scheduleForDateRange(
  Ref ref,
  DateTime start,
  DateTime end,
) {
  final db = ref.watch(appDatabaseProvider);
  final tasksStream = db.scheduledTasksDao.watchTasksForDateRange(start, end, includeCompleted: true);
  final eventsStream = db.eventsDao.watchEventsForDateRange(start, end, includeCompleted: true);
  final deadlinesStream = db.deadlinesDao.watchAllDeadlinesForDateRange(start, end, includeCompleted: true);

  return tasksStream.asyncExpand((tasks) async* {
    await for (final events in eventsStream) {
      await for (final deadlines in deadlinesStream) {
        final allItems = <ScheduleItem>[
          ...tasks.map(ScheduleItem.fromScheduledTask),
          ...events.map(ScheduleItem.fromEvent),
          ...deadlines.map(ScheduleItem.fromDeadline),
        ];

        allItems.sort(_compareScheduleItems);

        final days = _groupItemsByDate(allItems);
        yield days;
      }
    }
  });
}

int _compareScheduleItems(ScheduleItem a, ScheduleItem b) {
  if (a.itemType == ScheduleItemType.event && b.itemType != ScheduleItemType.event) {
    return -1;
  }
  if (a.itemType != ScheduleItemType.event && b.itemType == ScheduleItemType.event) {
    return 1;
  }

  final aDate = a.endDate ?? a.startDate;
  final bDate = b.endDate ?? b.startDate;

  if (aDate == null && bDate == null) return 0;
  if (aDate == null) return 1;
  if (bDate == null) return -1;

  final dateCompare = aDate.compareTo(bDate);
  if (dateCompare != 0) return dateCompare;

  final aStartDate = a.startDate ?? aDate;
  final bStartDate = b.startDate ?? bDate;
  return aStartDate.compareTo(bStartDate);
}

List<ScheduleDay> _groupItemsByDate(List<ScheduleItem> items) {
  final Map<String, List<ScheduleItem>> grouped = {};

  for (final item in items) {
    final date = item.endDate ?? item.startDate;
    if (date == null) continue;

    final key = '${date.year}-${date.month}-${date.day}';
    grouped.putIfAbsent(key, () => []);
    grouped[key]!.add(item);
  }

  final days = grouped.entries.map((entry) {
    final parts = entry.key.split('-');
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    return ScheduleDay(date: date, items: entry.value);
  }).toList();

  days.sort((a, b) => a.date.compareTo(b.date));
  return days;
}