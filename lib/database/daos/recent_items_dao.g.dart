// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_items_dao.dart';

// ignore_for_file: type=lint
mixin _$RecentItemsDaoMixin on DatabaseAccessor<AppDatabase> {
  $RecentItemsTable get recentItems => attachedDatabase.recentItems;
  RecentItemsDaoManager get managers => RecentItemsDaoManager(this);
}

class RecentItemsDaoManager {
  final _$RecentItemsDaoMixin _db;
  RecentItemsDaoManager(this._db);
  $$RecentItemsTableTableManager get recentItems =>
      $$RecentItemsTableTableManager(_db.attachedDatabase, _db.recentItems);
}
