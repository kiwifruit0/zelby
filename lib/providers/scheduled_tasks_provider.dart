import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/daos/scheduled_tasks_dao.dart' as dao;
import 'database_provider.dart';
import 'inbox_provider.dart';

part 'scheduled_tasks_provider.g.dart';

class ScheduledTaskWithDate {
  const ScheduledTaskWithDate({
    required this.item,
    required this.startDate,
    required this.endDate,
  });

  factory ScheduledTaskWithDate.fromDao(dao.ScheduledTaskWithDate value) {
    return ScheduledTaskWithDate(
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
Stream<List<ScheduledTaskWithDate>> scheduledTasksForDate(Ref ref, DateTime date) {
  final scheduledTasksDao = ref.watch(appDatabaseProvider).scheduledTasksDao;
  return scheduledTasksDao.watchTasksForDate(date).map(
        (rows) => rows.map(ScheduledTaskWithDate.fromDao).toList(),
      );
}
