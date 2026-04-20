import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/daos/deadlines_dao.dart' as dao;
import 'database_provider.dart';
import 'inbox_provider.dart';

part 'deadlines_provider.g.dart';

class DeadlineWithDate {
  const DeadlineWithDate({
    required this.item,
    required this.endDate,
  });

  factory DeadlineWithDate.fromDao(dao.DeadlineWithDate value) {
    return DeadlineWithDate(
      item: Item.fromDb(value.item),
      endDate: value.itemDate.endDate,
    );
  }

  final Item item;
  final DateTime? endDate;
}

@riverpod
Stream<List<DeadlineWithDate>> activeDeadlines(Ref ref) {
  final deadlinesDao = ref.watch(appDatabaseProvider).deadlinesDao;
  return deadlinesDao.watchActiveDeadlines().map(
        (rows) => rows.map(DeadlineWithDate.fromDao).toList(),
      );
}
