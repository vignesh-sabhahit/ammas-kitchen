import 'shelf_life_data.dart';

/// ~25 Dry Fruits, Nuts & Seeds
final List<ShelfLifeItem> dryfruitItems = [
  // --- Nuts ---
  ShelfLifeItem(name: 'Almonds', aliases: ['badam', 'badami', 'almond'], category: 'dryfruits', subcategory: 'nut', shelfDaysByLocation: {'pantry': 180, 'fridge': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 250, isPerishable: false, source: 'usda'),
  ShelfLifeItem(name: 'Cashews', aliases: ['kaju', 'godambi', 'munthiri', 'cashew nut'], category: 'dryfruits', subcategory: 'nut', shelfDaysByLocation: {'pantry': 180, 'fridge': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 250, isPerishable: false, source: 'usda'),
  ShelfLifeItem(name: 'Walnuts', aliases: ['akhrot', 'akrotu', 'walnut'], category: 'dryfruits', subcategory: 'nut', shelfDaysByLocation: {'pantry': 90, 'fridge': 180}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, isPerishable: false, source: 'usda'),
  ShelfLifeItem(name: 'Pistachios', aliases: ['pista', 'pistachio'], category: 'dryfruits', subcategory: 'nut', shelfDaysByLocation: {'pantry': 180, 'fridge': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, isPerishable: false, source: 'usda'),
  ShelfLifeItem(name: 'Peanuts', aliases: ['moongfali', 'shengdana', 'kadlekayi', 'verkadalai', 'groundnut'], category: 'dryfruits', subcategory: 'nut', shelfDaysByLocation: {'pantry': 120, 'fridge': 180}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 500, isPerishable: false, source: 'usda'),
  ShelfLifeItem(name: 'Pine Nuts', aliases: ['chilgoza', 'pine nuts'], category: 'dryfruits', subcategory: 'nut', shelfDaysByLocation: {'fridge': 90}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 100, isPerishable: false, source: 'custom'),

  // --- Dried fruits ---
  ShelfLifeItem(name: 'Raisins', aliases: ['kishmish', 'drakshi', 'manuka', 'golden raisins', 'munakka', 'dry grapes'], category: 'dryfruits', subcategory: 'dried', shelfDaysByLocation: {'pantry': 180, 'fridge': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, isPerishable: false, source: 'usda'),
  ShelfLifeItem(name: 'Dates', aliases: ['khajoor', 'kharjura', 'dry dates', 'medjool', 'ajwa dates', 'deglet nour'], category: 'dryfruits', subcategory: 'dried', shelfDaysByLocation: {'pantry': 180, 'fridge': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 250, isPerishable: false, source: 'usda'),
  ShelfLifeItem(name: 'Dried Figs', aliases: ['anjeer', 'dried figs', 'anjir'], category: 'dryfruits', subcategory: 'dried', shelfDaysByLocation: {'pantry': 180, 'fridge': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Dried Apricots', aliases: ['khumani', 'apricot', 'dried apricot', 'jardalu'], category: 'dryfruits', subcategory: 'dried', shelfDaysByLocation: {'pantry': 180, 'fridge': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Prunes', aliases: ['prunes', 'dried plum', 'aloo bukhara'], category: 'dryfruits', subcategory: 'dried', shelfDaysByLocation: {'pantry': 180}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Cranberries', aliases: ['dried cranberries', 'cranberry'], category: 'dryfruits', subcategory: 'dried', shelfDaysByLocation: {'pantry': 180}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Tutti Frutti', aliases: ['tutti frutti', 'candied fruit'], category: 'dryfruits', subcategory: 'dried', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 100, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Desiccated Coconut', aliases: ['coconut powder', 'dry coconut powder', 'desiccated coconut'], category: 'dryfruits', subcategory: 'dried', shelfDaysByLocation: {'pantry': 180, 'fridge': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 100, isPerishable: false, source: 'custom'),

  // --- Seeds ---
  ShelfLifeItem(name: 'Flax Seeds', aliases: ['alsi', 'agase', 'ali virai', 'flaxseed', 'linseed'], category: 'dryfruits', subcategory: 'seed', shelfDaysByLocation: {'pantry': 180, 'fridge': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Chia Seeds', aliases: ['chia seeds', 'chia', 'sabja', 'basil seeds'], category: 'dryfruits', subcategory: 'seed', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Sunflower Seeds', aliases: ['sunflower seeds', 'surajmukhi beej'], category: 'dryfruits', subcategory: 'seed', shelfDaysByLocation: {'pantry': 180, 'fridge': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Pumpkin Seeds', aliases: ['pumpkin seeds', 'kaddu ke beej'], category: 'dryfruits', subcategory: 'seed', shelfDaysByLocation: {'pantry': 180, 'fridge': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Watermelon Seeds', aliases: ['magaz', 'tarbooz ke beej', 'watermelon seeds', 'char magaz'], category: 'dryfruits', subcategory: 'seed', shelfDaysByLocation: {'pantry': 180}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 100, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Lotus Seeds', aliases: ['makhana', 'fox nuts', 'phool makhana', 'lotus seeds'], category: 'dryfruits', subcategory: 'seed', shelfDaysByLocation: {'pantry': 180}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, isPerishable: false, source: 'custom'),
];
