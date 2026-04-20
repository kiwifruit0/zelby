// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deadlines_dao.dart';

// ignore_for_file: type=lint
mixin _$DeadlinesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ItemsTable get items => attachedDatabase.items;
  $ItemDatesTable get itemDates => attachedDatabase.itemDates;
  DeadlinesDaoManager get managers => DeadlinesDaoManager(this);
}

class DeadlinesDaoManager {
  final _$DeadlinesDaoMixin _db;
  DeadlinesDaoManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$ItemDatesTableTableManager get itemDates =>
      $$ItemDatesTableTableManager(_db.attachedDatabase, _db.itemDates);
}
