// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift.dart';

// ignore_for_file: type=lint
class $StringItemsTable extends StringItems
    with TableInfo<$StringItemsTable, StringItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StringItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'string_items';
  @override
  VerificationContext validateIntegrity(Insertable<StringItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StringItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StringItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $StringItemsTable createAlias(String alias) {
    return $StringItemsTable(attachedDatabase, alias);
  }
}

class StringItem extends DataClass implements Insertable<StringItem> {
  final int id;
  final String value;
  const StringItem({required this.id, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['value'] = Variable<String>(value);
    return map;
  }

  StringItemsCompanion toCompanion(bool nullToAbsent) {
    return StringItemsCompanion(
      id: Value(id),
      value: Value(value),
    );
  }

  factory StringItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StringItem(
      id: serializer.fromJson<int>(json['id']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'value': serializer.toJson<String>(value),
    };
  }

  StringItem copyWith({int? id, String? value}) => StringItem(
        id: id ?? this.id,
        value: value ?? this.value,
      );
  StringItem copyWithCompanion(StringItemsCompanion data) {
    return StringItem(
      id: data.id.present ? data.id.value : this.id,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StringItem(')
          ..write('id: $id, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StringItem && other.id == this.id && other.value == this.value);
}

class StringItemsCompanion extends UpdateCompanion<StringItem> {
  final Value<int> id;
  final Value<String> value;
  const StringItemsCompanion({
    this.id = const Value.absent(),
    this.value = const Value.absent(),
  });
  StringItemsCompanion.insert({
    this.id = const Value.absent(),
    required String value,
  }) : value = Value(value);
  static Insertable<StringItem> custom({
    Expression<int>? id,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (value != null) 'value': value,
    });
  }

  StringItemsCompanion copyWith({Value<int>? id, Value<String>? value}) {
    return StringItemsCompanion(
      id: id ?? this.id,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StringItemsCompanion(')
          ..write('id: $id, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StringItemsTable stringItems = $StringItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [stringItems];
}

typedef $$StringItemsTableCreateCompanionBuilder = StringItemsCompanion
    Function({
  Value<int> id,
  required String value,
});
typedef $$StringItemsTableUpdateCompanionBuilder = StringItemsCompanion
    Function({
  Value<int> id,
  Value<String> value,
});

class $$StringItemsTableFilterComposer
    extends Composer<_$AppDatabase, $StringItemsTable> {
  $$StringItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$StringItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $StringItemsTable> {
  $$StringItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$StringItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StringItemsTable> {
  $$StringItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$StringItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StringItemsTable,
    StringItem,
    $$StringItemsTableFilterComposer,
    $$StringItemsTableOrderingComposer,
    $$StringItemsTableAnnotationComposer,
    $$StringItemsTableCreateCompanionBuilder,
    $$StringItemsTableUpdateCompanionBuilder,
    (StringItem, BaseReferences<_$AppDatabase, $StringItemsTable, StringItem>),
    StringItem,
    PrefetchHooks Function()> {
  $$StringItemsTableTableManager(_$AppDatabase db, $StringItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StringItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StringItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StringItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> value = const Value.absent(),
          }) =>
              StringItemsCompanion(
            id: id,
            value: value,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String value,
          }) =>
              StringItemsCompanion.insert(
            id: id,
            value: value,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StringItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StringItemsTable,
    StringItem,
    $$StringItemsTableFilterComposer,
    $$StringItemsTableOrderingComposer,
    $$StringItemsTableAnnotationComposer,
    $$StringItemsTableCreateCompanionBuilder,
    $$StringItemsTableUpdateCompanionBuilder,
    (StringItem, BaseReferences<_$AppDatabase, $StringItemsTable, StringItem>),
    StringItem,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StringItemsTableTableManager get stringItems =>
      $$StringItemsTableTableManager(_db, _db.stringItems);
}
