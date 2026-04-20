import 'package:drift/drift.dart';

import 'items.dart';

class ProjectItems extends Table {
  IntColumn get projectId =>
      integer().named('project_id').references(Items, #id)();

  IntColumn get itemId => integer().named('item_id').references(Items, #id)();

  TextColumn get itemType =>
      text().named('item_type').customConstraint(itemTypeCheckConstraint)();

  @override
  Set<Column<Object>> get primaryKey => {projectId, itemId, itemType};
}
