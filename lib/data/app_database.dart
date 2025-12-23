import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static bool _factoryInitialized = false;
  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }
    _database = await _openDatabase();
    return _database!;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<Database> _openDatabase() async {
    _initDatabaseFactory();
    final dbPath =
        p.join(await getDatabasesPath(), 'maintenance_management.db');
    return openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createTables(db);
        await _createIndexes(db);
        await _seedInitialData(db);
      },
    );
  }

  void _initDatabaseFactory() {
    if (kIsWeb || _factoryInitialized) {
      return;
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _factoryInitialized = true;
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
CREATE TABLE site (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  is_active INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE workshop (
  id INTEGER PRIMARY KEY,
  site_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (site_id) REFERENCES site(id),
  UNIQUE (site_id, name)
)
''');

    await db.execute('''
CREATE TABLE production_line (
  id INTEGER PRIMARY KEY,
  workshop_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (workshop_id) REFERENCES workshop(id),
  UNIQUE (workshop_id, name)
)
''');

    await db.execute('''
CREATE TABLE machine_model (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  is_active INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE machine (
  id INTEGER PRIMARY KEY,
  machine_model_id INTEGER NOT NULL,
  machine_no TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (machine_model_id) REFERENCES machine_model(id),
  UNIQUE (machine_model_id, machine_no)
)
''');

    await db.execute('''
CREATE TABLE anomaly_category (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  is_active INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE anomaly_class (
  id INTEGER PRIMARY KEY,
  category_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (category_id) REFERENCES anomaly_category(id),
  UNIQUE (category_id, name)
)
''');

    await db.execute('''
CREATE TABLE group_tbl (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  is_active INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE person (
  id INTEGER PRIMARY KEY,
  group_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (group_id) REFERENCES group_tbl(id),
  UNIQUE (group_id, name)
)
''');

    await db.execute('''
CREATE TABLE shift (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  sort_order INTEGER NOT NULL DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE maintenance_record (
  id INTEGER PRIMARY KEY,
  record_date TEXT NOT NULL,
  shift_id INTEGER NOT NULL,
  line_id INTEGER NOT NULL,
  machine_id INTEGER NOT NULL,
  anomaly_class_id INTEGER NOT NULL,
  description TEXT NOT NULL,
  solution TEXT NOT NULL,
  is_fixed INTEGER NOT NULL DEFAULT 0,
  fixed_at TEXT,
  duration_minutes INTEGER NOT NULL DEFAULT 0,
  owner_id INTEGER NOT NULL,
  FOREIGN KEY (shift_id) REFERENCES shift(id),
  FOREIGN KEY (line_id) REFERENCES production_line(id),
  FOREIGN KEY (machine_id) REFERENCES machine(id),
  FOREIGN KEY (anomaly_class_id) REFERENCES anomaly_class(id),
  FOREIGN KEY (owner_id) REFERENCES person(id),
  CHECK (is_fixed IN (0,1)),
  CHECK (
    (is_fixed = 0 AND fixed_at IS NULL) OR
    (is_fixed = 1 AND fixed_at IS NOT NULL)
  ),
  CHECK (duration_minutes >= 0)
)
''');

    await db.execute('''
CREATE TABLE maintenance_record_fixer (
  record_id INTEGER NOT NULL,
  person_id INTEGER NOT NULL,
  PRIMARY KEY (record_id, person_id),
  FOREIGN KEY (record_id) REFERENCES maintenance_record(id),
  FOREIGN KEY (person_id) REFERENCES person(id)
)
''');
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
        'CREATE INDEX idx_record_date ON maintenance_record(record_date)');
    await db.execute(
        'CREATE INDEX idx_record_line ON maintenance_record(line_id)');
    await db.execute(
        'CREATE INDEX idx_record_machine ON maintenance_record(machine_id)');
    await db.execute(
        'CREATE INDEX idx_record_fixed ON maintenance_record(is_fixed)');
    await db.execute('CREATE INDEX idx_record_anomaly '
        'ON maintenance_record(anomaly_class_id)');
    await db.execute(
        'CREATE INDEX idx_record_owner ON maintenance_record(owner_id)');
  }

  Future<void> _seedInitialData(Database db) async {
    final batch = db.batch();
    batch.insert('shift', {'id': 1, 'name': '白班', 'sort_order': 1});
    batch.insert('shift', {'id': 2, 'name': '夜班', 'sort_order': 2});

    batch.insert(
        'site', {'id': 1, 'name': '一厂', 'is_active': 1, 'sort_order': 1});
    batch.insert(
        'site', {'id': 2, 'name': '二厂', 'is_active': 1, 'sort_order': 2});

    batch.insert('workshop', {
      'id': 1,
      'site_id': 1,
      'name': 'A车间',
      'is_active': 1,
      'sort_order': 1
    });
    batch.insert('workshop', {
      'id': 2,
      'site_id': 1,
      'name': 'B车间',
      'is_active': 1,
      'sort_order': 2
    });
    batch.insert('workshop', {
      'id': 3,
      'site_id': 2,
      'name': 'C车间',
      'is_active': 1,
      'sort_order': 1
    });

    batch.insert('production_line', {
      'id': 1,
      'workshop_id': 1,
      'name': '1号线',
      'is_active': 1,
      'sort_order': 1
    });
    batch.insert('production_line', {
      'id': 2,
      'workshop_id': 1,
      'name': '2号线',
      'is_active': 1,
      'sort_order': 2
    });
    batch.insert('production_line', {
      'id': 3,
      'workshop_id': 2,
      'name': '3号线',
      'is_active': 1,
      'sort_order': 1
    });

    batch.insert('machine_model', {
      'id': 1,
      'name': 'M-100',
      'is_active': 1,
      'sort_order': 1
    });
    batch.insert('machine_model', {
      'id': 2,
      'name': 'M-200',
      'is_active': 1,
      'sort_order': 2
    });

    batch.insert('machine', {
      'id': 1,
      'machine_model_id': 1,
      'machine_no': 'T-01',
      'is_active': 1,
      'sort_order': 1
    });
    batch.insert('machine', {
      'id': 2,
      'machine_model_id': 1,
      'machine_no': 'T-02',
      'is_active': 1,
      'sort_order': 2
    });
    batch.insert('machine', {
      'id': 3,
      'machine_model_id': 2,
      'machine_no': 'T-03',
      'is_active': 1,
      'sort_order': 1
    });

    batch.insert('anomaly_category', {
      'id': 1,
      'name': '电气类',
      'is_active': 1,
      'sort_order': 1
    });
    batch.insert('anomaly_category', {
      'id': 2,
      'name': '机械类',
      'is_active': 1,
      'sort_order': 2
    });
    batch.insert('anomaly_category', {
      'id': 3,
      'name': '软件类',
      'is_active': 1,
      'sort_order': 3
    });

    batch.insert('anomaly_class', {
      'id': 1,
      'category_id': 1,
      'name': '传感器',
      'is_active': 1,
      'sort_order': 1
    });
    batch.insert('anomaly_class', {
      'id': 2,
      'category_id': 1,
      'name': '电机',
      'is_active': 1,
      'sort_order': 2
    });
    batch.insert('anomaly_class', {
      'id': 3,
      'category_id': 2,
      'name': '皮带',
      'is_active': 1,
      'sort_order': 1
    });

    batch.insert('group_tbl', {
      'id': 1,
      'name': 'A组',
      'is_active': 1,
      'sort_order': 1
    });
    batch.insert('group_tbl', {
      'id': 2,
      'name': 'B组',
      'is_active': 1,
      'sort_order': 2
    });

    batch.insert('person', {
      'id': 1,
      'group_id': 1,
      'name': '王伟',
      'is_active': 1,
      'sort_order': 1
    });
    batch.insert('person', {
      'id': 2,
      'group_id': 1,
      'name': '李敏',
      'is_active': 1,
      'sort_order': 2
    });
    batch.insert('person', {
      'id': 3,
      'group_id': 2,
      'name': '陈杰',
      'is_active': 1,
      'sort_order': 1
    });

    await batch.commit(noResult: true);
  }
}
