import 'package:drift/drift.dart';

import 'items.dart';

class ItemDates extends Table {
  IntColumn get itemId => integer().named('item_id').references(Items, #id)();

  DateTimeColumn get startDate => dateTime().named('start_date').nullable()();

  DateTimeColumn get endDate => dateTime().named('end_date').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {itemId};
}
