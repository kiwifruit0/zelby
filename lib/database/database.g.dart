// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rruleMeta = const VerificationMeta('rrule');
  @override
  late final GeneratedColumn<String> rrule = GeneratedColumn<String>(
    'rrule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    notes,
    itemType,
    completed,
    completedAt,
    deletedAt,
    createdAt,
    updatedAt,
    rrule,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<Item> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('rrule')) {
      context.handle(
        _rruleMeta,
        rrule.isAcceptableOrUnknown(data['rrule']!, _rruleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      rrule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rrule'],
      ),
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final int id;
  final String title;
  final String? notes;
  final String itemType;
  final bool completed;
  final DateTime? completedAt;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? rrule;
  const Item({
    required this.id,
    required this.title,
    this.notes,
    required this.itemType,
    required this.completed,
    this.completedAt,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.rrule,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['item_type'] = Variable<String>(itemType);
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || rrule != null) {
      map['rrule'] = Variable<String>(rrule);
    }
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      itemType: Value(itemType),
      completed: Value(completed),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      rrule: rrule == null && nullToAbsent
          ? const Value.absent()
          : Value(rrule),
    );
  }

  factory Item.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      itemType: serializer.fromJson<String>(json['itemType']),
      completed: serializer.fromJson<bool>(json['completed']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      rrule: serializer.fromJson<String?>(json['rrule']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'itemType': serializer.toJson<String>(itemType),
      'completed': serializer.toJson<bool>(completed),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'rrule': serializer.toJson<String?>(rrule),
    };
  }

  Item copyWith({
    int? id,
    String? title,
    Value<String?> notes = const Value.absent(),
    String? itemType,
    bool? completed,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> rrule = const Value.absent(),
  }) => Item(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    itemType: itemType ?? this.itemType,
    completed: completed ?? this.completed,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    rrule: rrule.present ? rrule.value : this.rrule,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      completed: data.completed.present ? data.completed.value : this.completed,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rrule: data.rrule.present ? data.rrule.value : this.rrule,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('itemType: $itemType, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rrule: $rrule')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    itemType,
    completed,
    completedAt,
    deletedAt,
    createdAt,
    updatedAt,
    rrule,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.itemType == this.itemType &&
          other.completed == this.completed &&
          other.completedAt == this.completedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.rrule == this.rrule);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> notes;
  final Value<String> itemType;
  final Value<bool> completed;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> deletedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> rrule;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.itemType = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rrule = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.notes = const Value.absent(),
    required String itemType,
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rrule = const Value.absent(),
  }) : title = Value(title),
       itemType = Value(itemType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Item> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<String>? itemType,
    Expression<bool>? completed,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? rrule,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (itemType != null) 'item_type': itemType,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completed_at': completedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rrule != null) 'rrule': rrule,
    });
  }

  ItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? notes,
    Value<String>? itemType,
    Value<bool>? completed,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? deletedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? rrule,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      itemType: itemType ?? this.itemType,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rrule: rrule ?? this.rrule,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rrule.present) {
      map['rrule'] = Variable<String>(rrule.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('itemType: $itemType, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rrule: $rrule')
          ..write(')'))
        .toString();
  }
}

class $ItemDatesTable extends ItemDates
    with TableInfo<$ItemDatesTable, ItemDate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemDatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [itemId, startDate, endDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_dates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemDate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  ItemDate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemDate(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
    );
  }

  @override
  $ItemDatesTable createAlias(String alias) {
    return $ItemDatesTable(attachedDatabase, alias);
  }
}

class ItemDate extends DataClass implements Insertable<ItemDate> {
  final int itemId;
  final DateTime? startDate;
  final DateTime? endDate;
  const ItemDate({required this.itemId, this.startDate, this.endDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<int>(itemId);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    return map;
  }

  ItemDatesCompanion toCompanion(bool nullToAbsent) {
    return ItemDatesCompanion(
      itemId: Value(itemId),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
    );
  }

  factory ItemDate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemDate(
      itemId: serializer.fromJson<int>(json['itemId']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<int>(itemId),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
    };
  }

  ItemDate copyWith({
    int? itemId,
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
  }) => ItemDate(
    itemId: itemId ?? this.itemId,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
  );
  ItemDate copyWithCompanion(ItemDatesCompanion data) {
    return ItemDate(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemDate(')
          ..write('itemId: $itemId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, startDate, endDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemDate &&
          other.itemId == this.itemId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate);
}

class ItemDatesCompanion extends UpdateCompanion<ItemDate> {
  final Value<int> itemId;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  const ItemDatesCompanion({
    this.itemId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
  });
  ItemDatesCompanion.insert({
    this.itemId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
  });
  static Insertable<ItemDate> custom({
    Expression<int>? itemId,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
  }

  ItemDatesCompanion copyWith({
    Value<int>? itemId,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
  }) {
    return ItemDatesCompanion(
      itemId: itemId ?? this.itemId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemDatesCompanion(')
          ..write('itemId: $itemId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }
}

class $ProjectItemsTable extends ProjectItems
    with TableInfo<$ProjectItemsTable, ProjectItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [projectId, itemId, itemType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {projectId, itemId, itemType};
  @override
  ProjectItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectItem(
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
    );
  }

  @override
  $ProjectItemsTable createAlias(String alias) {
    return $ProjectItemsTable(attachedDatabase, alias);
  }
}

class ProjectItem extends DataClass implements Insertable<ProjectItem> {
  final int projectId;
  final int itemId;
  final String itemType;
  const ProjectItem({
    required this.projectId,
    required this.itemId,
    required this.itemType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['project_id'] = Variable<int>(projectId);
    map['item_id'] = Variable<int>(itemId);
    map['item_type'] = Variable<String>(itemType);
    return map;
  }

  ProjectItemsCompanion toCompanion(bool nullToAbsent) {
    return ProjectItemsCompanion(
      projectId: Value(projectId),
      itemId: Value(itemId),
      itemType: Value(itemType),
    );
  }

  factory ProjectItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectItem(
      projectId: serializer.fromJson<int>(json['projectId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      itemType: serializer.fromJson<String>(json['itemType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'projectId': serializer.toJson<int>(projectId),
      'itemId': serializer.toJson<int>(itemId),
      'itemType': serializer.toJson<String>(itemType),
    };
  }

  ProjectItem copyWith({int? projectId, int? itemId, String? itemType}) =>
      ProjectItem(
        projectId: projectId ?? this.projectId,
        itemId: itemId ?? this.itemId,
        itemType: itemType ?? this.itemType,
      );
  ProjectItem copyWithCompanion(ProjectItemsCompanion data) {
    return ProjectItem(
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectItem(')
          ..write('projectId: $projectId, ')
          ..write('itemId: $itemId, ')
          ..write('itemType: $itemType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(projectId, itemId, itemType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectItem &&
          other.projectId == this.projectId &&
          other.itemId == this.itemId &&
          other.itemType == this.itemType);
}

class ProjectItemsCompanion extends UpdateCompanion<ProjectItem> {
  final Value<int> projectId;
  final Value<int> itemId;
  final Value<String> itemType;
  final Value<int> rowid;
  const ProjectItemsCompanion({
    this.projectId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.itemType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectItemsCompanion.insert({
    required int projectId,
    required int itemId,
    required String itemType,
    this.rowid = const Value.absent(),
  }) : projectId = Value(projectId),
       itemId = Value(itemId),
       itemType = Value(itemType);
  static Insertable<ProjectItem> custom({
    Expression<int>? projectId,
    Expression<int>? itemId,
    Expression<String>? itemType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (projectId != null) 'project_id': projectId,
      if (itemId != null) 'item_id': itemId,
      if (itemType != null) 'item_type': itemType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectItemsCompanion copyWith({
    Value<int>? projectId,
    Value<int>? itemId,
    Value<String>? itemType,
    Value<int>? rowid,
  }) {
    return ProjectItemsCompanion(
      projectId: projectId ?? this.projectId,
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectItemsCompanion(')
          ..write('projectId: $projectId, ')
          ..write('itemId: $itemId, ')
          ..write('itemType: $itemType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskDependenciesTable extends TaskDependencies
    with TableInfo<$TaskDependenciesTable, TaskDependency> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskDependenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  static const VerificationMeta _dependsOnIdMeta = const VerificationMeta(
    'dependsOnId',
  );
  @override
  late final GeneratedColumn<int> dependsOnId = GeneratedColumn<int>(
    'depends_on_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [taskId, dependsOnId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_dependencies';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskDependency> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('depends_on_id')) {
      context.handle(
        _dependsOnIdMeta,
        dependsOnId.isAcceptableOrUnknown(
          data['depends_on_id']!,
          _dependsOnIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dependsOnIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId, dependsOnId};
  @override
  TaskDependency map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskDependency(
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      dependsOnId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}depends_on_id'],
      )!,
    );
  }

  @override
  $TaskDependenciesTable createAlias(String alias) {
    return $TaskDependenciesTable(attachedDatabase, alias);
  }
}

class TaskDependency extends DataClass implements Insertable<TaskDependency> {
  final int taskId;
  final int dependsOnId;
  const TaskDependency({required this.taskId, required this.dependsOnId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<int>(taskId);
    map['depends_on_id'] = Variable<int>(dependsOnId);
    return map;
  }

  TaskDependenciesCompanion toCompanion(bool nullToAbsent) {
    return TaskDependenciesCompanion(
      taskId: Value(taskId),
      dependsOnId: Value(dependsOnId),
    );
  }

  factory TaskDependency.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskDependency(
      taskId: serializer.fromJson<int>(json['taskId']),
      dependsOnId: serializer.fromJson<int>(json['dependsOnId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<int>(taskId),
      'dependsOnId': serializer.toJson<int>(dependsOnId),
    };
  }

  TaskDependency copyWith({int? taskId, int? dependsOnId}) => TaskDependency(
    taskId: taskId ?? this.taskId,
    dependsOnId: dependsOnId ?? this.dependsOnId,
  );
  TaskDependency copyWithCompanion(TaskDependenciesCompanion data) {
    return TaskDependency(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      dependsOnId: data.dependsOnId.present
          ? data.dependsOnId.value
          : this.dependsOnId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskDependency(')
          ..write('taskId: $taskId, ')
          ..write('dependsOnId: $dependsOnId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(taskId, dependsOnId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskDependency &&
          other.taskId == this.taskId &&
          other.dependsOnId == this.dependsOnId);
}

class TaskDependenciesCompanion extends UpdateCompanion<TaskDependency> {
  final Value<int> taskId;
  final Value<int> dependsOnId;
  final Value<int> rowid;
  const TaskDependenciesCompanion({
    this.taskId = const Value.absent(),
    this.dependsOnId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskDependenciesCompanion.insert({
    required int taskId,
    required int dependsOnId,
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       dependsOnId = Value(dependsOnId);
  static Insertable<TaskDependency> custom({
    Expression<int>? taskId,
    Expression<int>? dependsOnId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (dependsOnId != null) 'depends_on_id': dependsOnId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskDependenciesCompanion copyWith({
    Value<int>? taskId,
    Value<int>? dependsOnId,
    Value<int>? rowid,
  }) {
    return TaskDependenciesCompanion(
      taskId: taskId ?? this.taskId,
      dependsOnId: dependsOnId ?? this.dependsOnId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (dependsOnId.present) {
      map['depends_on_id'] = Variable<int>(dependsOnId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskDependenciesCompanion(')
          ..write('taskId: $taskId, ')
          ..write('dependsOnId: $dependsOnId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $ItemDatesTable itemDates = $ItemDatesTable(this);
  late final $ProjectItemsTable projectItems = $ProjectItemsTable(this);
  late final $TaskDependenciesTable taskDependencies = $TaskDependenciesTable(
    this,
  );
  late final InboxDao inboxDao = InboxDao(this as AppDatabase);
  late final ScheduledTasksDao scheduledTasksDao = ScheduledTasksDao(
    this as AppDatabase,
  );
  late final EventsDao eventsDao = EventsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    items,
    itemDates,
    projectItems,
    taskDependencies,
  ];
}

typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> notes,
      required String itemType,
      Value<bool> completed,
      Value<DateTime?> completedAt,
      Value<DateTime?> deletedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> rrule,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> notes,
      Value<String> itemType,
      Value<bool> completed,
      Value<DateTime?> completedAt,
      Value<DateTime?> deletedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> rrule,
    });

final class $$ItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemsTable, Item> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemDatesTable, List<ItemDate>>
  _itemDatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itemDates,
    aliasName: $_aliasNameGenerator(db.items.id, db.itemDates.itemId),
  );

  $$ItemDatesTableProcessedTableManager get itemDatesRefs {
    final manager = $$ItemDatesTableTableManager(
      $_db,
      $_db.itemDates,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemDatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rrule => $composableBuilder(
    column: $table.rrule,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> itemDatesRefs(
    Expression<bool> Function($$ItemDatesTableFilterComposer f) f,
  ) {
    final $$ItemDatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemDates,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemDatesTableFilterComposer(
            $db: $db,
            $table: $db.itemDates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rrule => $composableBuilder(
    column: $table.rrule,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get rrule =>
      $composableBuilder(column: $table.rrule, builder: (column) => column);

  Expression<T> itemDatesRefs<T extends Object>(
    Expression<T> Function($$ItemDatesTableAnnotationComposer a) f,
  ) {
    final $$ItemDatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemDates,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemDatesTableAnnotationComposer(
            $db: $db,
            $table: $db.itemDates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          Item,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (Item, $$ItemsTableReferences),
          Item,
          PrefetchHooks Function({bool itemDatesRefs})
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> rrule = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                title: title,
                notes: notes,
                itemType: itemType,
                completed: completed,
                completedAt: completedAt,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rrule: rrule,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> notes = const Value.absent(),
                required String itemType,
                Value<bool> completed = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> rrule = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                title: title,
                notes: notes,
                itemType: itemType,
                completed: completed,
                completedAt: completedAt,
                deletedAt: deletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rrule: rrule,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ItemsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({itemDatesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (itemDatesRefs) db.itemDates],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemDatesRefs)
                    await $_getPrefetchedData<Item, $ItemsTable, ItemDate>(
                      currentTable: table,
                      referencedTable: $$ItemsTableReferences
                          ._itemDatesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ItemsTableReferences(db, table, p0).itemDatesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.itemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      Item,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (Item, $$ItemsTableReferences),
      Item,
      PrefetchHooks Function({bool itemDatesRefs})
    >;
typedef $$ItemDatesTableCreateCompanionBuilder =
    ItemDatesCompanion Function({
      Value<int> itemId,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
    });
typedef $$ItemDatesTableUpdateCompanionBuilder =
    ItemDatesCompanion Function({
      Value<int> itemId,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
    });

final class $$ItemDatesTableReferences
    extends BaseReferences<_$AppDatabase, $ItemDatesTable, ItemDate> {
  $$ItemDatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.itemDates.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItemDatesTableFilterComposer
    extends Composer<_$AppDatabase, $ItemDatesTable> {
  $$ItemDatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemDatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemDatesTable> {
  $$ItemDatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemDatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemDatesTable> {
  $$ItemDatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemDatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemDatesTable,
          ItemDate,
          $$ItemDatesTableFilterComposer,
          $$ItemDatesTableOrderingComposer,
          $$ItemDatesTableAnnotationComposer,
          $$ItemDatesTableCreateCompanionBuilder,
          $$ItemDatesTableUpdateCompanionBuilder,
          (ItemDate, $$ItemDatesTableReferences),
          ItemDate,
          PrefetchHooks Function({bool itemId})
        > {
  $$ItemDatesTableTableManager(_$AppDatabase db, $ItemDatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemDatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemDatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemDatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> itemId = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
              }) => ItemDatesCompanion(
                itemId: itemId,
                startDate: startDate,
                endDate: endDate,
              ),
          createCompanionCallback:
              ({
                Value<int> itemId = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
              }) => ItemDatesCompanion.insert(
                itemId: itemId,
                startDate: startDate,
                endDate: endDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ItemDatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable: $$ItemDatesTableReferences
                                    ._itemIdTable(db),
                                referencedColumn: $$ItemDatesTableReferences
                                    ._itemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ItemDatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemDatesTable,
      ItemDate,
      $$ItemDatesTableFilterComposer,
      $$ItemDatesTableOrderingComposer,
      $$ItemDatesTableAnnotationComposer,
      $$ItemDatesTableCreateCompanionBuilder,
      $$ItemDatesTableUpdateCompanionBuilder,
      (ItemDate, $$ItemDatesTableReferences),
      ItemDate,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$ProjectItemsTableCreateCompanionBuilder =
    ProjectItemsCompanion Function({
      required int projectId,
      required int itemId,
      required String itemType,
      Value<int> rowid,
    });
typedef $$ProjectItemsTableUpdateCompanionBuilder =
    ProjectItemsCompanion Function({
      Value<int> projectId,
      Value<int> itemId,
      Value<String> itemType,
      Value<int> rowid,
    });

final class $$ProjectItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectItemsTable, ProjectItem> {
  $$ProjectItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _projectIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.projectItems.projectId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemsTable _itemIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.projectItems.itemId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProjectItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectItemsTable> {
  $$ProjectItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get projectId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectItemsTable> {
  $$ProjectItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get projectId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectItemsTable> {
  $$ProjectItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  $$ItemsTableAnnotationComposer get projectId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectItemsTable,
          ProjectItem,
          $$ProjectItemsTableFilterComposer,
          $$ProjectItemsTableOrderingComposer,
          $$ProjectItemsTableAnnotationComposer,
          $$ProjectItemsTableCreateCompanionBuilder,
          $$ProjectItemsTableUpdateCompanionBuilder,
          (ProjectItem, $$ProjectItemsTableReferences),
          ProjectItem,
          PrefetchHooks Function({bool projectId, bool itemId})
        > {
  $$ProjectItemsTableTableManager(_$AppDatabase db, $ProjectItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> projectId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectItemsCompanion(
                projectId: projectId,
                itemId: itemId,
                itemType: itemType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int projectId,
                required int itemId,
                required String itemType,
                Value<int> rowid = const Value.absent(),
              }) => ProjectItemsCompanion.insert(
                projectId: projectId,
                itemId: itemId,
                itemType: itemType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false, itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$ProjectItemsTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$ProjectItemsTableReferences
                                    ._projectIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable: $$ProjectItemsTableReferences
                                    ._itemIdTable(db),
                                referencedColumn: $$ProjectItemsTableReferences
                                    ._itemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProjectItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectItemsTable,
      ProjectItem,
      $$ProjectItemsTableFilterComposer,
      $$ProjectItemsTableOrderingComposer,
      $$ProjectItemsTableAnnotationComposer,
      $$ProjectItemsTableCreateCompanionBuilder,
      $$ProjectItemsTableUpdateCompanionBuilder,
      (ProjectItem, $$ProjectItemsTableReferences),
      ProjectItem,
      PrefetchHooks Function({bool projectId, bool itemId})
    >;
typedef $$TaskDependenciesTableCreateCompanionBuilder =
    TaskDependenciesCompanion Function({
      required int taskId,
      required int dependsOnId,
      Value<int> rowid,
    });
typedef $$TaskDependenciesTableUpdateCompanionBuilder =
    TaskDependenciesCompanion Function({
      Value<int> taskId,
      Value<int> dependsOnId,
      Value<int> rowid,
    });

final class $$TaskDependenciesTableReferences
    extends
        BaseReferences<_$AppDatabase, $TaskDependenciesTable, TaskDependency> {
  $$TaskDependenciesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ItemsTable _taskIdTable(_$AppDatabase db) => db.items.createAlias(
    $_aliasNameGenerator(db.taskDependencies.taskId, db.items.id),
  );

  $$ItemsTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<int>('task_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemsTable _dependsOnIdTable(_$AppDatabase db) =>
      db.items.createAlias(
        $_aliasNameGenerator(db.taskDependencies.dependsOnId, db.items.id),
      );

  $$ItemsTableProcessedTableManager get dependsOnId {
    final $_column = $_itemColumn<int>('depends_on_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dependsOnIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskDependenciesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskDependenciesTable> {
  $$TaskDependenciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ItemsTableFilterComposer get taskId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableFilterComposer get dependsOnId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dependsOnId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskDependenciesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskDependenciesTable> {
  $$TaskDependenciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ItemsTableOrderingComposer get taskId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableOrderingComposer get dependsOnId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dependsOnId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskDependenciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskDependenciesTable> {
  $$TaskDependenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ItemsTableAnnotationComposer get taskId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableAnnotationComposer get dependsOnId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dependsOnId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskDependenciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskDependenciesTable,
          TaskDependency,
          $$TaskDependenciesTableFilterComposer,
          $$TaskDependenciesTableOrderingComposer,
          $$TaskDependenciesTableAnnotationComposer,
          $$TaskDependenciesTableCreateCompanionBuilder,
          $$TaskDependenciesTableUpdateCompanionBuilder,
          (TaskDependency, $$TaskDependenciesTableReferences),
          TaskDependency,
          PrefetchHooks Function({bool taskId, bool dependsOnId})
        > {
  $$TaskDependenciesTableTableManager(
    _$AppDatabase db,
    $TaskDependenciesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskDependenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskDependenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskDependenciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> taskId = const Value.absent(),
                Value<int> dependsOnId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskDependenciesCompanion(
                taskId: taskId,
                dependsOnId: dependsOnId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int taskId,
                required int dependsOnId,
                Value<int> rowid = const Value.absent(),
              }) => TaskDependenciesCompanion.insert(
                taskId: taskId,
                dependsOnId: dependsOnId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskDependenciesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false, dependsOnId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable:
                                    $$TaskDependenciesTableReferences
                                        ._taskIdTable(db),
                                referencedColumn:
                                    $$TaskDependenciesTableReferences
                                        ._taskIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (dependsOnId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.dependsOnId,
                                referencedTable:
                                    $$TaskDependenciesTableReferences
                                        ._dependsOnIdTable(db),
                                referencedColumn:
                                    $$TaskDependenciesTableReferences
                                        ._dependsOnIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TaskDependenciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskDependenciesTable,
      TaskDependency,
      $$TaskDependenciesTableFilterComposer,
      $$TaskDependenciesTableOrderingComposer,
      $$TaskDependenciesTableAnnotationComposer,
      $$TaskDependenciesTableCreateCompanionBuilder,
      $$TaskDependenciesTableUpdateCompanionBuilder,
      (TaskDependency, $$TaskDependenciesTableReferences),
      TaskDependency,
      PrefetchHooks Function({bool taskId, bool dependsOnId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$ItemDatesTableTableManager get itemDates =>
      $$ItemDatesTableTableManager(_db, _db.itemDates);
  $$ProjectItemsTableTableManager get projectItems =>
      $$ProjectItemsTableTableManager(_db, _db.projectItems);
  $$TaskDependenciesTableTableManager get taskDependencies =>
      $$TaskDependenciesTableTableManager(_db, _db.taskDependencies);
}
