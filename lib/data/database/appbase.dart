import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;
  AppDatabase._init();

  static const int _dbVersion = 2;
  static const String _dbName = 'treklist.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lists(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        color TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        priority INTEGER DEFAULT 2,
        status INTEGER DEFAULT 1,
        tags TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(list_id) REFERENCES lists(id) ON DELETE CASCADE
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try { await db.execute("ALTER TABLE lists ADD COLUMN description TEXT;"); } catch (_) {}
      try { await db.execute("ALTER TABLE lists ADD COLUMN color TEXT;"); } catch (_) {}
      try { await db.execute("ALTER TABLE lists ADD COLUMN created_at TEXT;"); } catch (_) {}
      try { await db.execute("ALTER TABLE lists ADD COLUMN updated_at TEXT;"); } catch (_) {}

      try { await db.execute("ALTER TABLE tasks ADD COLUMN description TEXT;"); } catch (_) {}
      try { await db.execute("ALTER TABLE tasks ADD COLUMN due_date TEXT;"); } catch (_) {}
      try { await db.execute("ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 2;"); } catch (_) {}
      try { await db.execute("ALTER TABLE tasks ADD COLUMN status INTEGER DEFAULT 1;"); } catch (_) {}
      try { await db.execute("ALTER TABLE tasks ADD COLUMN tags TEXT;"); } catch (_) {}
      try { await db.execute("ALTER TABLE tasks ADD COLUMN created_at TEXT;"); } catch (_) {}
      try { await db.execute("ALTER TABLE tasks ADD COLUMN updated_at TEXT;"); } catch (_) {}
    }
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
