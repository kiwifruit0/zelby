import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/daos/inbox_dao.dart';
import '../database/database.dart' as db;
import 'database_provider.dart';

part 'inbox_provider.g.dart';

class Item {
  const Item({
    required this.id,
    required this.title,
    required this.notes,
    required this.itemType,
    required this.completed,
    required this.completedAt,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.rrule,
  });

  factory Item.fromDb(db.Item item) {
    return Item(
      id: item.id,
      title: item.title,
      notes: item.notes,
      itemType: item.itemType,
      completed: item.completed,
      completedAt: item.completedAt,
      deletedAt: item.deletedAt,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      rrule: item.rrule,
    );
  }

  final int id;
  final String title;
  final String? notes;
  final String itemType;
  final bool completed;
  final DateTime? completedAt;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? rrule;
}

@riverpod
Stream<List<Item>> inboxTasks(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  final inboxDao = InboxDao(database);
  return inboxDao.watchInboxTasks().map(
        (rows) => rows.map(Item.fromDb).toList(),
      );
}
