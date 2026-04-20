// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_tasks_dao.dart';

// ignore_for_file: type=lint
mixin _$ScheduledTasksDaoMixin on DatabaseAccessor<AppDatabase> {
  $ItemsTable get items => attachedDatabase.items;
  $ItemDatesTable get itemDates => attachedDatabase.itemDates;
  ScheduledTasksDaoManager get managers => ScheduledTasksDaoManager(this);
}

class ScheduledTasksDaoManager {
  final _$ScheduledTasksDaoMixin _db;
  ScheduledTasksDaoManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$ItemDatesTableTableManager get itemDates =>
      $$ItemDatesTableTableManager(_db.attachedDatabase, _db.itemDates);
}
