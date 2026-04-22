import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/daos/today_dao.dart' as dao;
import 'database_provider.dart';
import 'inbox_provider.dart';

part 'today_provider.g.dart';

class TodayItem {
  const TodayItem({
    required this.item,
    required this.startDate,
    required this.endDate,
  });

  factory TodayItem.fromDao(dao.TodayItemWithDate value) {
    return TodayItem(
      item: Item.fromDb(value.item),
      startDate: value.itemDate.startDate,
      endDate: value.itemDate.endDate,
    );
  }

  final Item item;
  final DateTime? startDate;
  final DateTime? endDate;

  bool get isScheduledTask =>
      item.itemType == 'scheduled_task' || item.itemType == 'unscheduled_task';
  bool get isEvent => item.itemType == 'event';
  bool get isDeadline => item.itemType == 'deadline';
}

DateTime _todayDate() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

@riverpod
Stream<List<TodayItem>> todayActiveItems(Ref ref) {
  final todayDao = ref.watch(appDatabaseProvider).todayDao;
  return todayDao
      .watchTodayActiveItems(_todayDate())
      .map((rows) => rows.map(TodayItem.fromDao).toList());
}

@riverpod
Stream<List<TodayItem>> todayCompletedItems(Ref ref) {
  final todayDao = ref.watch(appDatabaseProvider).todayDao;
  return todayDao
      .watchTodayCompletedItems(_todayDate())
      .map((rows) => rows.map(TodayItem.fromDao).toList());
}
