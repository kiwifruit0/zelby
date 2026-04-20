import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/daos/events_dao.dart' as dao;
import 'database_provider.dart';
import 'inbox_provider.dart';

part 'events_provider.g.dart';

class EventWithDates {
  const EventWithDates({
    required this.item,
    required this.startDate,
    required this.endDate,
  });

  factory EventWithDates.fromDao(dao.EventWithDates value) {
    return EventWithDates(
      item: Item.fromDb(value.item),
      startDate: value.itemDate.startDate,
      endDate: value.itemDate.endDate,
    );
  }

  final Item item;
  final DateTime? startDate;
  final DateTime? endDate;
}

@riverpod
Stream<List<EventWithDates>> upcomingEvents(Ref ref) {
  final eventsDao = ref.watch(appDatabaseProvider).eventsDao;
  return eventsDao.watchUpcomingEvents().map(
        (rows) => rows.map(EventWithDates.fromDao).toList(),
      );
}

@riverpod
Stream<List<EventWithDates>> eventsForDateRange(
  Ref ref,
  DateTime start,
  DateTime end,
) {
  final eventsDao = ref.watch(appDatabaseProvider).eventsDao;
  return eventsDao.watchEventsForDateRange(start, end).map(
        (rows) => rows.map(EventWithDates.fromDao).toList(),
      );
}
