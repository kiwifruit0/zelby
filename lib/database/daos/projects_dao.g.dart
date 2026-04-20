// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects_dao.dart';

// ignore_for_file: type=lint
mixin _$ProjectsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ItemsTable get items => attachedDatabase.items;
  $ItemDatesTable get itemDates => attachedDatabase.itemDates;
  $ProjectItemsTable get projectItems => attachedDatabase.projectItems;
  ProjectsDaoManager get managers => ProjectsDaoManager(this);
}

class ProjectsDaoManager {
  final _$ProjectsDaoMixin _db;
  ProjectsDaoManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$ItemDatesTableTableManager get itemDates =>
      $$ItemDatesTableTableManager(_db.attachedDatabase, _db.itemDates);
  $$ProjectItemsTableTableManager get projectItems =>
      $$ProjectItemsTableTableManager(_db.attachedDatabase, _db.projectItems);
}
