// v2 Shelf Life Database for Amma's Kitchen
// ~500 items covering Indian vegetarian + egg household items
// Each item has aliases (English, Hindi, Kannada, brand names) for OCR fuzzy matching

// Category item files
import 'items_vegetables.dart';
import 'items_fruits.dart';
import 'items_dairy.dart';
import 'items_grains.dart';
import 'items_spices.dart';
import 'items_oils_condiments.dart';
import 'items_packaged.dart';
import 'items_beverages.dart';
import 'items_snacks_bakery.dart';
import 'items_dryfruits.dart';
import 'items_frozen_homemade.dart';
import 'items_extras.dart';

export 'items_vegetables.dart';
export 'items_fruits.dart';
export 'items_dairy.dart';
export 'items_grains.dart';
export 'items_spices.dart';
export 'items_oils_condiments.dart';
export 'items_packaged.dart';
export 'items_beverages.dart';
export 'items_snacks_bakery.dart';
export 'items_dryfruits.dart';
export 'items_frozen_homemade.dart';
export 'items_extras.dart';

class ShelfLifeItem {
  final String name;
  final List<String> aliases;
  final String category;
  final String subcategory;
  final Map<String, int> shelfDaysByLocation; // e.g. {'fridge': 7, 'pantry': 3}
  final String defaultLocation;
  final String defaultUnit;
  final bool isPerishable;
  final double typicalQuantity;
  final int? openedShelfDays; // shelf life after opening (for packaged goods)
  final String? brand; // null for generic items
  final String source;

  const ShelfLifeItem({
    required this.name,
    required this.aliases,
    required this.category,
    this.subcategory = '',
    required this.shelfDaysByLocation,
    required this.defaultLocation,
    this.defaultUnit = 'pieces',
    this.isPerishable = true,
    this.typicalQuantity = 1,
    this.openedShelfDays,
    this.brand,
    this.source = 'custom',
  });

  int? getShelfDays(String location) => shelfDaysByLocation[location];
  int get defaultShelfDays => shelfDaysByLocation[defaultLocation] ?? 7;

  /// Returns all searchable terms (name + all aliases, lowercased)
  List<String> get searchTerms => [name.toLowerCase(), ...aliases.map((a) => a.toLowerCase())];
}

// ============================================================================
// CATEGORIES & DISPLAY CONSTANTS
// ============================================================================

const Map<String, String> categoryIcons = {
  'vegetable': '🥬',
  'fruit': '🍎',
  'dairy': '🥛',
  'egg': '🥚',
  'grain': '🌾',
  'spice': '🌶️',
  'oil': '🫒',
  'condiment': '🫙',
  'packaged': '📦',
  'beverage': '🥤',
  'snack': '🍪',
  'frozen': '🧊',
  'bakery': '🍞',
  'dryfruits': '🥜',
  'homemade': '🍲',
  'other': '🏷️',
};

const Map<String, String> categoryNames = {
  'vegetable': 'Vegetables',
  'fruit': 'Fruits',
  'dairy': 'Dairy',
  'egg': 'Eggs',
  'grain': 'Grains & Pulses',
  'spice': 'Spices & Masalas',
  'oil': 'Oils & Ghee',
  'condiment': 'Condiments & Sauces',
  'packaged': 'Packaged Food',
  'beverage': 'Beverages',
  'snack': 'Snacks & Namkeen',
  'frozen': 'Frozen Food',
  'bakery': 'Bakery & Bread',
  'dryfruits': 'Dry Fruits & Nuts',
  'homemade': 'Homemade/Fresh',
  'other': 'Other',
};

const Map<String, String> locationIcons = {
  'fridge': '❄️',
  'freezer': '🧊',
  'pantry': '🏠',
  'shelf': '📚',
  'countertop': '🍽️',
  'other': '📍',
};

const List<String> storageLocations = [
  'fridge',
  'freezer',
  'pantry',
  'shelf',
  'countertop',
  'other',
];

const List<String> unitOptions = [
  'pieces',
  'packets',
  'kg',
  'g',
  'L',
  'ml',
  'dozen',
  'bunch',
  'bottles',
  'boxes',
  'cans',
  'bags',
  'sachets',
];

// ============================================================================
// MASTER DATABASE — ~500 items
// ============================================================================

final List<ShelfLifeItem> shelfLifeDatabase = [
  // -------------------------------------------------------
  // VEGETABLES (~55 items)
  // -------------------------------------------------------
  ...vegetableItems,
  // -------------------------------------------------------
  // FRUITS (~35 items)
  // -------------------------------------------------------
  ...fruitItems,
  // -------------------------------------------------------
  // DAIRY (~30 items)
  // -------------------------------------------------------
  ...dairyItems,
  // -------------------------------------------------------
  // EGGS (~5 items)
  // -------------------------------------------------------
  ...eggItems,
  // -------------------------------------------------------
  // GRAINS, FLOUR & PULSES (~50 items)
  // -------------------------------------------------------
  ...grainItems,
  // -------------------------------------------------------
  // SPICES & MASALAS (~55 items)
  // -------------------------------------------------------
  ...spiceItems,
  // -------------------------------------------------------
  // OILS & GHEE (~20 items)
  // -------------------------------------------------------
  ...oilItems,
  // -------------------------------------------------------
  // CONDIMENTS & SAUCES (~35 items)
  // -------------------------------------------------------
  ...condimentItems,
  // -------------------------------------------------------
  // PACKAGED FOOD (~50 items)
  // -------------------------------------------------------
  ...packagedItems,
  // -------------------------------------------------------
  // BEVERAGES (~25 items)
  // -------------------------------------------------------
  ...beverageItems,
  // -------------------------------------------------------
  // SNACKS & NAMKEEN (~20 items)
  // -------------------------------------------------------
  ...snackItems,
  // -------------------------------------------------------
  // BAKERY & BREAD (~10 items)
  // -------------------------------------------------------
  ...bakeryItems,
  // -------------------------------------------------------
  // DRY FRUITS & NUTS (~25 items)
  // -------------------------------------------------------
  ...dryfruitItems,
  // -------------------------------------------------------
  // FROZEN FOOD (~15 items)
  // -------------------------------------------------------
  ...frozenItems,
  // -------------------------------------------------------
  // HOMEMADE / FRESH (~15 items)
  // -------------------------------------------------------
  ...homemadeItems,
  // -------------------------------------------------------
  // EXTRAS — more brands, regional, organic (~100 items)
  // -------------------------------------------------------
  ...extraDairyItems,
  ...extraPackagedItems,
  ...extraSnackItems,
  ...extraBeverageItems,
  ...extraVegetableItems,
  ...extraOilItems,
  ...organicItems,
  ...extraFruitItems,
  ...miscItems,
];

// ============================================================================
// CATEGORY DEFAULTS (fallback when no specific item matches)
// ============================================================================

final List<ShelfLifeItem> categoryDefaults = [
  ShelfLifeItem(name: 'vegetable', aliases: [], category: 'vegetable', shelfDaysByLocation: {'fridge': 5, 'pantry': 3, 'freezer': 30}, defaultLocation: 'fridge', source: 'default'),
  ShelfLifeItem(name: 'fruit', aliases: [], category: 'fruit', shelfDaysByLocation: {'fridge': 7, 'pantry': 4, 'freezer': 30}, defaultLocation: 'fridge', source: 'default'),
  ShelfLifeItem(name: 'dairy', aliases: [], category: 'dairy', shelfDaysByLocation: {'fridge': 5, 'freezer': 30}, defaultLocation: 'fridge', source: 'default'),
  ShelfLifeItem(name: 'egg', aliases: [], category: 'egg', shelfDaysByLocation: {'fridge': 21, 'pantry': 7}, defaultLocation: 'fridge', source: 'default'),
  ShelfLifeItem(name: 'grain', aliases: [], category: 'grain', shelfDaysByLocation: {'pantry': 180}, defaultLocation: 'pantry', isPerishable: false, source: 'default'),
  ShelfLifeItem(name: 'spice', aliases: [], category: 'spice', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', isPerishable: false, source: 'default'),
  ShelfLifeItem(name: 'oil', aliases: [], category: 'oil', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', isPerishable: false, source: 'default'),
  ShelfLifeItem(name: 'condiment', aliases: [], category: 'condiment', shelfDaysByLocation: {'fridge': 90, 'pantry': 60}, defaultLocation: 'pantry', source: 'default'),
  ShelfLifeItem(name: 'packaged', aliases: [], category: 'packaged', shelfDaysByLocation: {'pantry': 90}, defaultLocation: 'pantry', source: 'default'),
  ShelfLifeItem(name: 'beverage', aliases: [], category: 'beverage', shelfDaysByLocation: {'fridge': 7, 'pantry': 180}, defaultLocation: 'fridge', source: 'default'),
  ShelfLifeItem(name: 'snack', aliases: [], category: 'snack', shelfDaysByLocation: {'pantry': 60}, defaultLocation: 'pantry', source: 'default'),
  ShelfLifeItem(name: 'frozen', aliases: [], category: 'frozen', shelfDaysByLocation: {'freezer': 90}, defaultLocation: 'freezer', source: 'default'),
  ShelfLifeItem(name: 'bakery', aliases: [], category: 'bakery', shelfDaysByLocation: {'pantry': 3, 'fridge': 7}, defaultLocation: 'pantry', source: 'default'),
  ShelfLifeItem(name: 'dryfruits', aliases: [], category: 'dryfruits', shelfDaysByLocation: {'pantry': 180}, defaultLocation: 'pantry', isPerishable: false, source: 'default'),
  ShelfLifeItem(name: 'homemade', aliases: [], category: 'homemade', shelfDaysByLocation: {'fridge': 3, 'freezer': 14}, defaultLocation: 'fridge', source: 'default'),
  ShelfLifeItem(name: 'other', aliases: [], category: 'other', shelfDaysByLocation: {'pantry': 30}, defaultLocation: 'pantry', source: 'default'),
];
