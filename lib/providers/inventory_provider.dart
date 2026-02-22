import 'package:flutter/foundation.dart';
import 'package:ammas_kitchen/models/inventory_item.dart';
import 'package:ammas_kitchen/services/database_service.dart';
import 'package:ammas_kitchen/services/notification_service.dart';

enum SortMode { byExpiry, byName, byDateAdded, byCategory }

class InventoryProvider extends ChangeNotifier {
  List<InventoryItem> _items = [];
  List<InventoryItem> _filteredItems = [];
  String _searchQuery = '';
  String? _filterLocation;
  String? _filterCategory;
  bool _showExpiringOnly = false;
  SortMode _sortMode = SortMode.byExpiry;

  List<InventoryItem> get items =>
      _searchQuery.isEmpty &&
              _filterLocation == null &&
              _filterCategory == null &&
              !_showExpiringOnly
          ? _items
          : _filteredItems;

  List<InventoryItem> get expiringItems => _items
      .where((item) =>
          item.expiryStatus == ExpiryStatus.soon ||
          item.expiryStatus == ExpiryStatus.today ||
          item.expiryStatus == ExpiryStatus.expired)
      .toList();

  int get totalItems => _items.length;
  int get expiringCount => expiringItems.length;

  String? get filterLocation => _filterLocation;
  String? get filterCategory => _filterCategory;
  bool get showExpiringOnly => _showExpiringOnly;
  SortMode get sortMode => _sortMode;

  void setSortMode(SortMode mode) {
    _sortMode = mode;
    _items.sort(_getComparator());
    _applyFilters();
    notifyListeners();
  }

  final DatabaseService _db = DatabaseService.instance;

  Future<void> loadItems() async {
    _items = await _db.getActiveItems();
    _applyFilters();
    notifyListeners();
  }

  Future<void> addItem(InventoryItem item) async {
    final id = await _db.insertItem(item);
    final newItem = item.copyWith(id: id);
    _items.add(newItem);
    _items.sort(_getComparator());
    _applyFilters();

    // Schedule notification if item has expiry date
    if (newItem.expiryDate != null && newItem.id != null) {
      await NotificationService.instance
          .scheduleExpiryNotification(newItem);
    }

    notifyListeners();
  }

  Future<void> updateItem(InventoryItem item) async {
    await _db.updateItem(item);
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      _items.sort(_getComparator());
      _applyFilters();
    }

    // Reschedule notification
    if (item.id != null) {
      await NotificationService.instance.cancelNotification(item.id!);
      if (item.expiryDate != null) {
        await NotificationService.instance
            .scheduleExpiryNotification(item);
      }
    }

    notifyListeners();
  }

  Future<void> updateQuantity(int itemId, double newQuantity) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;

    if (newQuantity <= 0) {
      await markUsed(itemId);
      return;
    }

    final updated = _items[index].copyWith(quantity: newQuantity);
    await _db.updateItem(updated);
    _items[index] = updated;
    _applyFilters();
    notifyListeners();
  }

  Future<InventoryItem?> markUsed(int itemId) async {
    await _db.markItemUsed(itemId);
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index == -1) return null;
    final removed = _items.removeAt(index);
    _applyFilters();

    // Cancel notification
    await NotificationService.instance.cancelNotification(itemId);

    notifyListeners();
    return removed;
  }

  Future<void> undoMarkUsed(InventoryItem item) async {
    if (item.id == null) return;
    final restored = await _db.undoDelete(item.id!);
    if (restored != null) {
      _items.add(restored);
      _items.sort(_getComparator());
      _applyFilters();

      if (restored.expiryDate != null) {
        await NotificationService.instance
            .scheduleExpiryNotification(restored);
      }

      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setLocationFilter(String? location) {
    _filterLocation = location;
    _applyFilters();
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _filterCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setShowExpiringOnly(bool show) {
    _showExpiringOnly = show;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterLocation = null;
    _filterCategory = null;
    _showExpiringOnly = false;
    _filteredItems = List.from(_items);
    notifyListeners();
  }

  void _applyFilters() {
    _filteredItems = _items.where((item) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!item.name.toLowerCase().contains(q) &&
            !(item.brand?.toLowerCase().contains(q) ?? false) &&
            !item.category.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_filterLocation != null &&
          item.storageLocation != _filterLocation) {
        return false;
      }
      if (_filterCategory != null && item.category != _filterCategory) {
        return false;
      }
      if (_showExpiringOnly &&
          item.expiryStatus != ExpiryStatus.soon &&
          item.expiryStatus != ExpiryStatus.today &&
          item.expiryStatus != ExpiryStatus.expired) {
        return false;
      }
      return true;
    }).toList();
  }

  Comparator<InventoryItem> _getComparator() {
    switch (_sortMode) {
      case SortMode.byExpiry:
        return (a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return a.expiryDate!.compareTo(b.expiryDate!);
        };
      case SortMode.byName:
        return (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case SortMode.byDateAdded:
        return (a, b) => b.addedDate.compareTo(a.addedDate); // newest first
      case SortMode.byCategory:
        return (a, b) {
          final cmp = a.category.compareTo(b.category);
          if (cmp != 0) return cmp;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        };
    }
  }
}
