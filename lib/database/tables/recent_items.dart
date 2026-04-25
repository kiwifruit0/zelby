import 'package:drift/drift.dart';

class RecentItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // 'item' or 'route'
  IntColumn get itemId => integer().nullable()();
  TextColumn get route => text().nullable()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get iconKind => text()();
  DateTimeColumn get updatedAt => dateTime()();
}
