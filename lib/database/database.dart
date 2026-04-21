import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/deadlines_dao.dart';
import 'daos/events_dao.dart';
import 'daos/inbox_dao.dart';
import 'daos/projects_dao.dart';
import 'daos/scheduled_tasks_dao.dart';
import 'daos/today_dao.dart';
import 'tables/dependencies.dart';
import 'tables/item_dates.dart';
import 'tables/items.dart';
import 'tables/projects.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Items, ItemDates, ProjectItems, TaskDependencies],
  daos: [
    InboxDao,
    ScheduledTasksDao,
    EventsDao,
    DeadlinesDao,
    ProjectsDao,
    TodayDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._internal();

  factory AppDatabase() => instance;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'zelby',
    native: DriftNativeOptions(databasePath: _databasePath),
  );
}

Future<String> _databasePath() async {
  return 'zelby.db';
}
