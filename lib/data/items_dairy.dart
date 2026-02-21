import 'shelf_life_data.dart';

/// ~30 Dairy items + ~5 Egg items with brand aliases
final List<ShelfLifeItem> dairyItems = [
  // --- Milk ---
  ShelfLifeItem(name: 'Milk', aliases: ['doodh', 'haalu', 'paal', 'fresh milk', 'toned milk', 'full cream milk'], category: 'dairy', subcategory: 'milk', shelfDaysByLocation: {'fridge': 4}, defaultLocation: 'fridge', defaultUnit: 'L', typicalQuantity: 1, source: 'usda'),
  ShelfLifeItem(name: 'Nandini Milk', aliases: ['nandini', 'nandini toned milk', 'nandini gold', 'nandini good life', 'kmf milk', 'kmf nandini'], category: 'dairy', subcategory: 'milk', shelfDaysByLocation: {'fridge': 4}, defaultLocation: 'fridge', defaultUnit: 'L', typicalQuantity: 1, brand: 'Nandini', source: 'custom'),
  ShelfLifeItem(name: 'Amul Taaza Milk', aliases: ['amul taaza', 'amul toned milk', 'amul milk'], category: 'dairy', subcategory: 'milk', shelfDaysByLocation: {'fridge': 4}, defaultLocation: 'fridge', defaultUnit: 'L', typicalQuantity: 1, brand: 'Amul', source: 'custom'),
  ShelfLifeItem(name: 'UHT Milk', aliases: ['tetra pack milk', 'long life milk', 'amul taaza tetra', 'nestle a+ tetra'], category: 'dairy', subcategory: 'milk', shelfDaysByLocation: {'pantry': 180, 'fridge': 7}, defaultLocation: 'pantry', defaultUnit: 'L', typicalQuantity: 1, openedShelfDays: 5, source: 'custom'),
  ShelfLifeItem(name: 'Flavoured Milk', aliases: ['badam milk', 'chocolate milk', 'amul kool', 'nandini flavoured milk', 'amul lassi'], category: 'dairy', subcategory: 'milk', shelfDaysByLocation: {'fridge': 5}, defaultLocation: 'fridge', defaultUnit: 'ml', typicalQuantity: 200, source: 'custom'),

  // --- Curd & Yogurt ---
  ShelfLifeItem(name: 'Curd', aliases: ['dahi', 'mosaru', 'thayir', 'yogurt', 'yoghurt', 'plain curd'], category: 'dairy', subcategory: 'curd', shelfDaysByLocation: {'fridge': 7}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 400, source: 'custom'),
  ShelfLifeItem(name: 'Nandini Curd', aliases: ['nandini mosaru', 'nandini dahi', 'kmf curd'], category: 'dairy', subcategory: 'curd', shelfDaysByLocation: {'fridge': 7}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 400, brand: 'Nandini', source: 'custom'),
  ShelfLifeItem(name: 'Amul Masti Dahi', aliases: ['amul dahi', 'amul masti', 'amul curd'], category: 'dairy', subcategory: 'curd', shelfDaysByLocation: {'fridge': 10}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 400, brand: 'Amul', source: 'custom'),
  ShelfLifeItem(name: 'Greek Yogurt', aliases: ['greek yogurt', 'epigamia', 'hung curd'], category: 'dairy', subcategory: 'curd', shelfDaysByLocation: {'fridge': 14}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 200, source: 'custom'),
  ShelfLifeItem(name: 'Buttermilk', aliases: ['chaas', 'majjige', 'mor', 'mattha', 'neer majjige'], category: 'dairy', subcategory: 'curd', shelfDaysByLocation: {'fridge': 3}, defaultLocation: 'fridge', defaultUnit: 'L', typicalQuantity: 0.5, source: 'custom'),
  ShelfLifeItem(name: 'Lassi', aliases: ['lassi', 'sweet lassi', 'amul lassi'], category: 'dairy', subcategory: 'curd', shelfDaysByLocation: {'fridge': 5}, defaultLocation: 'fridge', defaultUnit: 'ml', typicalQuantity: 200, source: 'custom'),
  ShelfLifeItem(name: 'Shrikhand', aliases: ['shrikhand', 'amul shrikhand'], category: 'dairy', subcategory: 'curd', shelfDaysByLocation: {'fridge': 10}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 100, source: 'custom'),

  // --- Paneer & Cheese ---
  ShelfLifeItem(name: 'Paneer', aliases: ['panir', 'cottage cheese indian', 'fresh paneer'], category: 'dairy', subcategory: 'cheese', shelfDaysByLocation: {'fridge': 4, 'freezer': 60}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 200, source: 'custom'),
  ShelfLifeItem(name: 'Amul Paneer', aliases: ['amul malai paneer', 'amul fresh paneer'], category: 'dairy', subcategory: 'cheese', shelfDaysByLocation: {'fridge': 7, 'freezer': 60}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 200, brand: 'Amul', openedShelfDays: 3, source: 'custom'),
  ShelfLifeItem(name: 'Tofu', aliases: ['tofu', 'soy paneer', 'bean curd'], category: 'dairy', subcategory: 'cheese', shelfDaysByLocation: {'fridge': 5, 'freezer': 60}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 200, source: 'custom'),
  ShelfLifeItem(name: 'Cheese Slices', aliases: ['amul cheese', 'britannia cheese', 'cheese slice', 'processed cheese'], category: 'dairy', subcategory: 'cheese', shelfDaysByLocation: {'fridge': 60}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 100, openedShelfDays: 14, source: 'custom'),
  ShelfLifeItem(name: 'Cheese Block', aliases: ['cheese block', 'amul cheese block', 'cheddar', 'gouda'], category: 'dairy', subcategory: 'cheese', shelfDaysByLocation: {'fridge': 30, 'freezer': 90}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 200, openedShelfDays: 14, source: 'usda'),
  ShelfLifeItem(name: 'Mozzarella', aliases: ['mozzarella', 'amul pizza cheese', 'pizza cheese', 'shredded cheese'], category: 'dairy', subcategory: 'cheese', shelfDaysByLocation: {'fridge': 21, 'freezer': 90}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 200, openedShelfDays: 7, source: 'custom'),
  ShelfLifeItem(name: 'Cream Cheese', aliases: ['cream cheese', 'philadelphia'], category: 'dairy', subcategory: 'cheese', shelfDaysByLocation: {'fridge': 14}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 200, openedShelfDays: 7, source: 'usda'),

  // --- Butter, Ghee, Cream ---
  ShelfLifeItem(name: 'Butter', aliases: ['makhan', 'benne', 'vennai', 'amul butter', 'britannia butter'], category: 'dairy', subcategory: 'fat', shelfDaysByLocation: {'fridge': 30, 'freezer': 120}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 100, source: 'usda'),
  ShelfLifeItem(name: 'Amul Butter', aliases: ['amul butter', 'amul salted butter', 'amul unsalted butter', 'amul pasteurised butter'], category: 'dairy', subcategory: 'fat', shelfDaysByLocation: {'fridge': 45, 'freezer': 120}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 100, brand: 'Amul', source: 'custom'),
  ShelfLifeItem(name: 'Ghee', aliases: ['desi ghee', 'tuppa', 'nei', 'clarified butter', 'amul ghee', 'nandini ghee', 'patanjali ghee'], category: 'dairy', subcategory: 'fat', shelfDaysByLocation: {'pantry': 270, 'fridge': 365}, defaultLocation: 'pantry', defaultUnit: 'L', typicalQuantity: 0.5, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Fresh Cream', aliases: ['cream', 'malai', 'amul cream', 'milky mist cream', 'whipping cream'], category: 'dairy', subcategory: 'fat', shelfDaysByLocation: {'fridge': 7, 'freezer': 30}, defaultLocation: 'fridge', defaultUnit: 'ml', typicalQuantity: 200, source: 'usda'),
  ShelfLifeItem(name: 'Condensed Milk', aliases: ['milkmaid', 'condensed milk', 'nestle milkmaid'], category: 'dairy', subcategory: 'fat', shelfDaysByLocation: {'pantry': 365, 'fridge': 14}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, brand: 'Nestle', openedShelfDays: 10, source: 'custom'),
  ShelfLifeItem(name: 'Milk Powder', aliases: ['doodh powder', 'everyday', 'nestle everyday', 'amulya', 'milk powder'], category: 'dairy', subcategory: 'milk', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, isPerishable: false, openedShelfDays: 30, source: 'custom'),
  ShelfLifeItem(name: 'Khoya', aliases: ['mawa', 'khoya', 'khoa'], category: 'dairy', subcategory: 'fat', shelfDaysByLocation: {'fridge': 5, 'freezer': 30}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 200, source: 'custom'),
];

final List<ShelfLifeItem> eggItems = [
  ShelfLifeItem(name: 'Eggs', aliases: ['anda', 'motte', 'muttai', 'egg', 'hen egg', 'country egg', 'desi anda'], category: 'egg', subcategory: 'fresh', shelfDaysByLocation: {'fridge': 21, 'pantry': 7}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 6, source: 'usda'),
  ShelfLifeItem(name: 'Boiled Eggs', aliases: ['ubla anda', 'bisi motte', 'hard boiled egg'], category: 'egg', subcategory: 'cooked', shelfDaysByLocation: {'fridge': 5}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 4, source: 'usda'),
  ShelfLifeItem(name: 'Quail Eggs', aliases: ['bater ke ande', 'quail eggs', 'kadai motte'], category: 'egg', subcategory: 'fresh', shelfDaysByLocation: {'fridge': 14}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 12, source: 'custom'),
];
