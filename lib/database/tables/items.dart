import 'package:drift/drift.dart';

const itemTypeCheckConstraint =
    "CHECK (item_type IN ('unscheduled_task', 'scheduled_task', 'event', 'deadline', 'project'))";

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get notes => text().nullable()();

  TextColumn get itemType =>
      text().named('item_type').customConstraint(itemTypeCheckConstraint)();

  BoolColumn get completed =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get completedAt => dateTime().named('completed_at').nullable()();

  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  TextColumn get rrule => text().nullable()();
}
