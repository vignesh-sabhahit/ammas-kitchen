import 'shelf_life_data.dart';

/// ~35 Fruit items with Hindi + Kannada aliases
final List<ShelfLifeItem> fruitItems = [
  // --- Everyday fruits ---
  ShelfLifeItem(name: 'Banana', aliases: ['kela', 'bale hannu', 'vaazhai pazham', 'banana'], category: 'fruit', subcategory: 'everyday', shelfDaysByLocation: {'pantry': 5, 'fridge': 7, 'freezer': 30}, defaultLocation: 'pantry', defaultUnit: 'pieces', typicalQuantity: 6, source: 'usda'),
  ShelfLifeItem(name: 'Apple', aliases: ['seb', 'sebu', 'apple'], category: 'fruit', subcategory: 'everyday', shelfDaysByLocation: {'fridge': 21, 'pantry': 5}, defaultLocation: 'fridge', defaultUnit: 'kg', typicalQuantity: 0.5, source: 'usda'),
  ShelfLifeItem(name: 'Mango', aliases: ['aam', 'maavina hannu', 'mangai', 'alphonso', 'hapus', 'totapuri', 'badami'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'pantry': 5, 'fridge': 10}, defaultLocation: 'pantry', defaultUnit: 'pieces', typicalQuantity: 3, source: 'custom'),
  ShelfLifeItem(name: 'Papaya', aliases: ['papita', 'paranga hannu', 'pappali', 'boppaayi'], category: 'fruit', subcategory: 'everyday', shelfDaysByLocation: {'fridge': 5, 'pantry': 3}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 1, source: 'custom'),
  ShelfLifeItem(name: 'Grapes', aliases: ['angoor', 'drakshi', 'draksha hannu', 'tiraksha'], category: 'fruit', subcategory: 'everyday', shelfDaysByLocation: {'fridge': 7}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 500, source: 'usda'),
  ShelfLifeItem(name: 'Orange', aliases: ['santra', 'narangi', 'kittale hannu', 'orange'], category: 'fruit', subcategory: 'everyday', shelfDaysByLocation: {'fridge': 14, 'pantry': 5}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 4, source: 'usda'),
  ShelfLifeItem(name: 'Pomegranate', aliases: ['anaar', 'dalimbe hannu', 'mathulai'], category: 'fruit', subcategory: 'everyday', shelfDaysByLocation: {'fridge': 14, 'pantry': 7}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 2, source: 'custom'),
  ShelfLifeItem(name: 'Guava', aliases: ['amrud', 'peru hannu', 'koiya', 'sebe hannu'], category: 'fruit', subcategory: 'everyday', shelfDaysByLocation: {'fridge': 5, 'pantry': 3}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 4, source: 'custom'),
  ShelfLifeItem(name: 'Lemon', aliases: ['nimbu', 'nimbe hannu', 'elumichai', 'lime'], category: 'fruit', subcategory: 'everyday', shelfDaysByLocation: {'fridge': 21, 'pantry': 7}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 6, source: 'usda'),

  // --- Seasonal fruits ---
  ShelfLifeItem(name: 'Watermelon', aliases: ['tarbooz', 'kallingana', 'tharbooja'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 5, 'pantry': 3}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 1, source: 'usda'),
  ShelfLifeItem(name: 'Muskmelon', aliases: ['kharbooja', 'kharbuja', 'kharbooj', 'cantaloupe'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 5, 'pantry': 2}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 1, source: 'usda'),
  ShelfLifeItem(name: 'Sapota', aliases: ['chikoo', 'chickoo', 'sapota', 'sapodilla', 'sapota hannu'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 5, 'pantry': 3}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 4, source: 'custom'),
  ShelfLifeItem(name: 'Coconut', aliases: ['nariyal', 'thenginkayi', 'kobbari', 'thengai'], category: 'fruit', subcategory: 'everyday', shelfDaysByLocation: {'pantry': 14, 'fridge': 21}, defaultLocation: 'pantry', defaultUnit: 'pieces', typicalQuantity: 1, source: 'custom'),
  ShelfLifeItem(name: 'Pineapple', aliases: ['ananas', 'ananas hannu', 'annasi pazham'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 5, 'pantry': 2}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 1, source: 'usda'),
  ShelfLifeItem(name: 'Jackfruit', aliases: ['kathal', 'halasu', 'palaa pazham', 'ripe jackfruit'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 5, 'pantry': 2}, defaultLocation: 'fridge', defaultUnit: 'kg', typicalQuantity: 1, source: 'custom'),
  ShelfLifeItem(name: 'Custard Apple', aliases: ['sitaphal', 'sharifa', 'seetaphal', 'sita phala'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'pantry': 3, 'fridge': 5}, defaultLocation: 'pantry', defaultUnit: 'pieces', typicalQuantity: 3, source: 'custom'),
  ShelfLifeItem(name: 'Fig', aliases: ['anjeer', 'athi hannu', 'fig', 'fresh fig'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 3}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 4, source: 'custom'),
  ShelfLifeItem(name: 'Jamun', aliases: ['java plum', 'nerale hannu', 'naval pazham', 'black plum'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 3}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 250, source: 'custom'),
  ShelfLifeItem(name: 'Litchi', aliases: ['lychee', 'litchi'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 5}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 250, source: 'custom'),
  ShelfLifeItem(name: 'Pear', aliases: ['nashpati', 'pear'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 10, 'pantry': 4}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 3, source: 'usda'),
  ShelfLifeItem(name: 'Plum', aliases: ['aloo bukhara', 'plum'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 5, 'pantry': 3}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 4, source: 'usda'),
  ShelfLifeItem(name: 'Strawberry', aliases: ['strawberry'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 5}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 200, source: 'usda'),
  ShelfLifeItem(name: 'Mosambi', aliases: ['sweet lime', 'mousambi', 'mosambi'], category: 'fruit', subcategory: 'everyday', shelfDaysByLocation: {'fridge': 14, 'pantry': 5}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 4, source: 'custom'),
  ShelfLifeItem(name: 'Kiwi', aliases: ['kiwi', 'kiwi fruit'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 14, 'pantry': 5}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 3, source: 'usda'),
  ShelfLifeItem(name: 'Pomelo', aliases: ['chakotra', 'bataviya nimbe', 'pomelo'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 14, 'pantry': 7}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 1, source: 'custom'),
  ShelfLifeItem(name: 'Dragon Fruit', aliases: ['dragon fruit', 'pitaya'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 5}, defaultLocation: 'fridge', defaultUnit: 'pieces', typicalQuantity: 2, source: 'custom'),
  ShelfLifeItem(name: 'Avocado', aliases: ['avocado', 'butter fruit'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'pantry': 4, 'fridge': 7}, defaultLocation: 'pantry', defaultUnit: 'pieces', typicalQuantity: 2, source: 'usda'),

  // --- Dates (fresh) ---
  ShelfLifeItem(name: 'Fresh Dates', aliases: ['khajur', 'fresh dates', 'khajoor', 'kharjura'], category: 'fruit', subcategory: 'seasonal', shelfDaysByLocation: {'fridge': 14, 'pantry': 5}, defaultLocation: 'fridge', defaultUnit: 'g', typicalQuantity: 250, source: 'custom'),
];
