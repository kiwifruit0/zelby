// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_dao.dart';

// ignore_for_file: type=lint
mixin _$SearchDaoMixin on DatabaseAccessor<AppDatabase> {
  $ItemsTable get items => attachedDatabase.items;
  $ItemDatesTable get itemDates => attachedDatabase.itemDates;
  $ProjectItemsTable get projectItems => attachedDatabase.projectItems;
  SearchDaoManager get managers => SearchDaoManager(this);
}

class SearchDaoManager {
  final _$SearchDaoMixin _db;
  SearchDaoManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db.attachedDatabase, _db.items);
  $$ItemDatesTableTableManager get itemDates =>
      $$ItemDatesTableTableManager(_db.attachedDatabase, _db.itemDates);
  $$ProjectItemsTableTableManager get projectItems =>
      $$ProjectItemsTableTableManager(_db.attachedDatabase, _db.projectItems);
}
