import 'package:drift/drift.dart';

import 'items.dart';

class TaskDependencies extends Table {
  IntColumn get taskId => integer().named('task_id').references(Items, #id)();

  IntColumn get dependsOnId =>
      integer().named('depends_on_id').references(Items, #id)();

  @override
  Set<Column<Object>> get primaryKey => {taskId, dependsOnId};
}
