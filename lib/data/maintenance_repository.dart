import 'package:maintenance_management/data/app_database.dart';
import 'package:maintenance_management/data/models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LookupTable {
  const LookupTable({
    required this.table,
    required this.nameColumn,
    this.parentColumn,
    this.hasActive = true,
  });

  final String table;
  final String nameColumn;
  final String? parentColumn;
  final bool hasActive;

  static const site =
      LookupTable(table: 'site', nameColumn: 'name');
  static const workshop = LookupTable(
    table: 'workshop',
    nameColumn: 'name',
    parentColumn: 'site_id',
  );
  static const productionLine = LookupTable(
    table: 'production_line',
    nameColumn: 'name',
    parentColumn: 'workshop_id',
  );
  static const machineModel =
      LookupTable(table: 'machine_model', nameColumn: 'name');
  static const machine = LookupTable(
    table: 'machine',
    nameColumn: 'machine_no',
    parentColumn: 'machine_model_id',
  );
  static const anomalyCategory =
      LookupTable(table: 'anomaly_category', nameColumn: 'name');
  static const anomalyClass = LookupTable(
    table: 'anomaly_class',
    nameColumn: 'name',
    parentColumn: 'category_id',
  );
  static const group = LookupTable(
    table: 'group_tbl',
    nameColumn: 'name',
  );
  static const person = LookupTable(
    table: 'person',
    nameColumn: 'name',
    parentColumn: 'group_id',
  );
  static const shift = LookupTable(
    table: 'shift',
    nameColumn: 'name',
    hasActive: false,
  );
}

class MaintenanceRepository {
  MaintenanceRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<LookupItem>> fetchLookup(
    LookupTable table, {
    int? parentId,
    bool onlyActive = true,
  }) async {
    final db = await _database.database;
    final where = <String>[];
    final args = <Object?>[];
    if (table.parentColumn != null && parentId != null) {
      where.add('${table.parentColumn} = ?');
      args.add(parentId);
    }
    if (table.hasActive && onlyActive) {
      where.add('is_active = 1');
    }
    final rows = await db.query(
      table.table,
      columns: ['id', table.nameColumn],
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'sort_order ASC, ${table.nameColumn} ASC',
    );
    return rows
        .map((row) => LookupItem(
              id: row['id'] as int,
              name: row[table.nameColumn] as String,
            ))
        .toList();
  }

  Future<List<LookupEntry>> fetchLookupEntries(
    LookupTable table, {
    int? parentId,
  }) async {
    final db = await _database.database;
    final where = <String>[];
    final args = <Object?>[];
    if (table.parentColumn != null && parentId != null) {
      where.add('${table.parentColumn} = ?');
      args.add(parentId);
    }
    final columns = <String>[
      'id',
      table.nameColumn,
      'sort_order',
      if (table.hasActive) 'is_active',
      if (table.parentColumn != null) table.parentColumn!,
    ];
    final rows = await db.query(
      table.table,
      columns: columns,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'sort_order ASC, ${table.nameColumn} ASC',
    );
    return rows
        .map((row) => LookupEntry(
              id: row['id'] as int,
              name: row[table.nameColumn] as String,
              sortOrder: (row['sort_order'] as int?) ?? 0,
              isActive: table.hasActive
                  ? (row['is_active'] as int? ?? 1) == 1
                  : true,
              parentId: table.parentColumn == null
                  ? null
                  : row[table.parentColumn] as int?,
            ))
        .toList();
  }

  Future<int> insertLookup(
    LookupTable table, {
    required String name,
    int? parentId,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    final db = await _database.database;
    final values = <String, Object?>{
      table.nameColumn: name,
      'sort_order': sortOrder,
    };
    if (table.parentColumn != null) {
      if (parentId == null) {
        throw ArgumentError('parentId is required for ${table.table}');
      }
      values[table.parentColumn!] = parentId;
    }
    if (table.hasActive) {
      values['is_active'] = isActive ? 1 : 0;
    }
    return db.insert(table.table, values);
  }

  Future<int> updateLookup(
    LookupTable table, {
    required int id,
    String? name,
    int? parentId,
    int? sortOrder,
    bool? isActive,
  }) async {
    final db = await _database.database;
    final values = <String, Object?>{};
    if (name != null) {
      values[table.nameColumn] = name;
    }
    if (parentId != null && table.parentColumn != null) {
      values[table.parentColumn!] = parentId;
    }
    if (sortOrder != null) {
      values['sort_order'] = sortOrder;
    }
    if (isActive != null && table.hasActive) {
      values['is_active'] = isActive ? 1 : 0;
    }
    if (values.isEmpty) {
      return 0;
    }
    return db.update(
      table.table,
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> setLookupActive(
    LookupTable table,
    int id,
    bool isActive,
  ) async {
    if (!table.hasActive) {
      throw ArgumentError('${table.table} does not support is_active');
    }
    return updateLookup(
      table,
      id: id,
      isActive: isActive,
    );
  }

  Future<int> deleteLookup(LookupTable table, int id) async {
    final db = await _database.database;
    return db.delete(
      table.table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertRecord(MaintenanceRecord record) async {
    final db = await _database.database;
    return db.transaction((txn) async {
      final recordId =
          await txn.insert('maintenance_record', record.toDbMap());
      if (record.fixerIds.isNotEmpty) {
        final batch = txn.batch();
        for (final personId in record.fixerIds) {
          batch.insert('maintenance_record_fixer', {
            'record_id': recordId,
            'person_id': personId,
          });
        }
        await batch.commit(noResult: true);
      }
      return recordId;
    });
  }

  Future<int> updateRecord(MaintenanceRecord record) async {
    if (record.id == null) {
      throw ArgumentError('record.id is required for update');
    }
    final db = await _database.database;
    return db.transaction((txn) async {
      final updated = await txn.update(
        'maintenance_record',
        record.toDbMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
      await txn.delete(
        'maintenance_record_fixer',
        where: 'record_id = ?',
        whereArgs: [record.id],
      );
      if (record.fixerIds.isNotEmpty) {
        final batch = txn.batch();
        for (final personId in record.fixerIds) {
          batch.insert('maintenance_record_fixer', {
            'record_id': record.id,
            'person_id': personId,
          });
        }
        await batch.commit(noResult: true);
      }
      return updated;
    });
  }

  Future<int> deleteRecord(int recordId) async {
    final db = await _database.database;
    return db.transaction((txn) async {
      await txn.delete(
        'maintenance_record_fixer',
        where: 'record_id = ?',
        whereArgs: [recordId],
      );
      return txn.delete(
        'maintenance_record',
        where: 'id = ?',
        whereArgs: [recordId],
      );
    });
  }

  Future<List<MaintenanceRecord>> fetchRecords({
    RecordQuery? query,
  }) async {
    final db = await _database.database;
    final where = <String>[];
    final args = <Object?>[];
    if (query?.startDate != null) {
      where.add('record_date >= ?');
      args.add(_formatDate(query!.startDate!));
    }
    if (query?.endDate != null) {
      where.add('record_date <= ?');
      args.add(_formatDate(query!.endDate!));
    }
    if (query?.shiftId != null) {
      where.add('shift_id = ?');
      args.add(query!.shiftId);
    }
    if (query?.lineId != null) {
      where.add('line_id = ?');
      args.add(query!.lineId);
    }
    if (query?.machineId != null) {
      where.add('machine_id = ?');
      args.add(query!.machineId);
    }
    if (query?.anomalyClassId != null) {
      where.add('anomaly_class_id = ?');
      args.add(query!.anomalyClassId);
    }
    if (query?.ownerId != null) {
      where.add('owner_id = ?');
      args.add(query!.ownerId);
    }
    if (query?.isFixed != null) {
      where.add('is_fixed = ?');
      args.add(query!.isFixed! ? 1 : 0);
    }
    final recordRows = await db.query(
      'maintenance_record',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'record_date DESC, id DESC',
    );
    if (recordRows.isEmpty) {
      return [];
    }

    final ids = recordRows.map((row) => row['id'] as int).toList();
    final fixerMap = await _fetchFixers(db, ids);

    return recordRows
        .map((row) => MaintenanceRecord.fromDbMap(
              row,
              fixerIds: fixerMap[row['id'] as int] ?? const [],
            ))
        .toList();
  }

  Future<Map<int, List<int>>> _fetchFixers(
    Database db,
    List<int> recordIds,
  ) async {
    if (recordIds.isEmpty) {
      return {};
    }
    final placeholders =
        List.filled(recordIds.length, '?').join(', ');
    final rows = await db.query(
      'maintenance_record_fixer',
      columns: ['record_id', 'person_id'],
      where: 'record_id IN ($placeholders)',
      whereArgs: recordIds,
    );
    final map = <int, List<int>>{};
    for (final row in rows) {
      final recordId = row['record_id'] as int;
      final personId = row['person_id'] as int;
      map.putIfAbsent(recordId, () => []).add(personId);
    }
    return map;
  }
}

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
