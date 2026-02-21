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
      version: 1,
      onCreate: _createDB,
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
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE shelf_life_defaults (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_name TEXT NOT NULL,
        category TEXT NOT NULL,
        location TEXT DEFAULT 'fridge',
        shelf_days INTEGER NOT NULL,
        source TEXT DEFAULT 'custom'
      )
    ''');

    // Seed shelf life defaults
    await _seedShelfLifeData(db);
  }

  Future<void> _seedShelfLifeData(Database db) async {
    final batch = db.batch();
    for (final entry in shelfLifeDefaults) {
      batch.insert('shelf_life_defaults', entry);
    }
    await batch.commit(noResult: true);
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

  // --- Shelf Life Defaults ---

  Future<int?> getShelfLifeDays(String itemName, String location) async {
    final db = await database;
    final maps = await db.query(
      'shelf_life_defaults',
      where: 'LOWER(item_name) = LOWER(?) AND LOWER(location) = LOWER(?)',
      whereArgs: [itemName, location],
    );
    if (maps.isNotEmpty) {
      return maps.first['shelf_days'] as int;
    }
    // Try category-based fallback
    return null;
  }

  Future<int?> getShelfLifeDaysByCategory(
      String category, String location) async {
    final db = await database;
    final maps = await db.query(
      'shelf_life_defaults',
      where:
          'LOWER(item_name) = LOWER(?) AND LOWER(location) = LOWER(?)',
      whereArgs: [category, location],
    );
    if (maps.isNotEmpty) {
      return maps.first['shelf_days'] as int;
    }
    return null;
  }
}
