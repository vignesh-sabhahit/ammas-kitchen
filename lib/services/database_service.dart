import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ammas_kitchen/models/inventory_item.dart';
import 'package:ammas_kitchen/data/shelf_life_data.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ammas_kitchen.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT DEFAULT 'other',
        quantity REAL DEFAULT 1,
        unit TEXT DEFAULT 'pieces',
        storage_location TEXT DEFAULT 'pantry',
        photo_path TEXT,
        expiry_date TEXT,
        mfg_date TEXT,
        is_perishable INTEGER DEFAULT 1,
        default_shelf_days INTEGER,
        added_date TEXT NOT NULL,
        updated_date TEXT NOT NULL,
        status TEXT DEFAULT 'active',
        notes TEXT,
        brand TEXT,
        photo_paths TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // v1 -> v2: Add brand and photo_paths columns, drop old shelf_life table
      try { await db.execute('ALTER TABLE items ADD COLUMN brand TEXT'); } catch (_) {}
      try { await db.execute('ALTER TABLE items ADD COLUMN photo_paths TEXT'); } catch (_) {}
      try { await db.execute('DROP TABLE IF EXISTS shelf_life_defaults'); } catch (_) {}
    }
  }

  // --- Item CRUD ---

  Future<int> insertItem(InventoryItem item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<InventoryItem>> getActiveItems() async {
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'expiry_date ASC',
    );
    return maps.map((map) => InventoryItem.fromMap(map)).toList();
  }

  Future<List<InventoryItem>> getExpiringItems({int withinDays = 3}) async {
    final db = await database;
    final now = DateTime.now();
    final cutoff = now.add(Duration(days: withinDays));
    final maps = await db.query(
      'items',
      where: 'status = ? AND expiry_date IS NOT NULL AND expiry_date <= ?',
      whereArgs: ['active', cutoff.toIso8601String()],
      orderBy: 'expiry_date ASC',
    );
    return maps.map((map) => InventoryItem.fromMap(map)).toList();
  }

  Future<int> updateItem(InventoryItem item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> markItemUsed(int id) async {
    final db = await database;
    return await db.update(
      'items',
      {'status': 'used', 'updated_date': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.update(
      'items',
      {'status': 'deleted', 'updated_date': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<InventoryItem?> undoDelete(int id) async {
    final db = await database;
    await db.update(
      'items',
      {'status': 'active', 'updated_date': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
    final maps = await db.query('items', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return InventoryItem.fromMap(maps.first);
  }

  Future<List<InventoryItem>> searchItems(String query) async {
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'status = ? AND name LIKE ?',
      whereArgs: ['active', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((map) => InventoryItem.fromMap(map)).toList();
  }

  Future<List<InventoryItem>> findDuplicates(String name) async {
    final db = await database;
    final maps = await db.query(
      'items',
      where: 'status = ? AND name LIKE ?',
      whereArgs: ['active', '%$name%'],
    );
    return maps.map((map) => InventoryItem.fromMap(map)).toList();
  }

  // =========================================================================
  // v2 SHELF LIFE LOOKUP — In-memory using ShelfLifeItem database
  // No more SQL queries for shelf life — all 423 items loaded in memory
  // =========================================================================

  /// Find the best matching ShelfLifeItem for a given name.
  /// Searches: exact name -> exact alias -> contains name -> contains alias
  ShelfLifeItem? findShelfLifeItem(String itemName) {
    final lower = itemName.toLowerCase().trim();
    if (lower.isEmpty) return null;

    // 1. Exact name match
    for (final item in shelfLifeDatabase) {
      if (item.name.toLowerCase() == lower) return item;
    }

    // 2. Exact alias match
    for (final item in shelfLifeDatabase) {
      for (final alias in item.aliases) {
        if (alias.toLowerCase() == lower) return item;
      }
    }

    // 3. Name contains search term or search term contains name
    for (final item in shelfLifeDatabase) {
      final itemLower = item.name.toLowerCase();
      if (itemLower.contains(lower) || lower.contains(itemLower)) {
        return item;
      }
    }

    // 4. Alias contains search term or search term contains alias
    for (final item in shelfLifeDatabase) {
      for (final alias in item.aliases) {
        final aliasLower = alias.toLowerCase();
        if (aliasLower.contains(lower) || lower.contains(aliasLower)) {
          return item;
        }
      }
    }

    return null;
  }

  /// Get shelf life days for an item name + location (sync)
  int? getShelfLifeDaysSync(String itemName, String location) {
    final item = findShelfLifeItem(itemName);
    if (item != null) {
      return item.getShelfDays(location) ?? item.defaultShelfDays;
    }
    return null;
  }

  /// Get shelf life by category fallback (sync)
  int? getShelfLifeByCategorySync(String category, String location) {
    for (final def in categoryDefaults) {
      if (def.name.toLowerCase() == category.toLowerCase()) {
        return def.getShelfDays(location);
      }
    }
    return null;
  }

  // Async wrappers for backward compatibility with v1 callers
  Future<int?> getShelfLifeDays(String itemName, String location) async {
    return getShelfLifeDaysSync(itemName, location);
  }

  Future<int?> getShelfLifeDaysByCategory(String category, String location) async {
    return getShelfLifeByCategorySync(category, location);
  }
}
