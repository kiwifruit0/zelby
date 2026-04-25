import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/daos/inbox_dao.dart';
import '../models/item.dart';
import 'database_provider.dart';

export '../models/item.dart';

part 'inbox_provider.g.dart';

@riverpod
Stream<List<Item>> inboxTasks(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  final inboxDao = InboxDao(database);
  return inboxDao.watchInboxTasks().map(
        (rows) => rows.map(Item.fromDb).toList(),
      );
}
