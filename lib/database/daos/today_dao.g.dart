// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_dao.dart';

// ignore_for_file: type=lint
mixin _$TodayDaoMixin on DatabaseAccessor<AppDatabase> {
  $ItemsTable get items => attachedDatabase.items;
  $ItemDatesTable get itemDates => attachedDatabase.itemDates;
  TodayDaoManager get managers => TodayDaoManager(this);
}

class TodayDaoManager {
  final _$TodayDaoMixin _db;
  TodayDaoManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$ItemDatesTableTableManager get itemDates =>
      $$ItemDatesTableTableManager(_db.attachedDatabase, _db.itemDates);
}
