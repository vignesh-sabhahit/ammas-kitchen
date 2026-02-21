import 'shelf_life_data.dart';

/// ~25 Beverages items
final List<ShelfLifeItem> beverageItems = [
  // --- Tea ---
  ShelfLifeItem(name: 'Tea Powder', aliases: ['chai patti', 'tea leaves', 'chaha pudi', 'tata tea', 'red label', 'brooke bond', 'wagh bakri', 'taj mahal tea', 'society tea'], category: 'beverage', subcategory: 'tea', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 250, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Green Tea', aliases: ['green tea', 'lipton green tea', 'tetley green tea', 'organic india tulsi', 'typhoo green tea'], category: 'beverage', subcategory: 'tea', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'boxes', typicalQuantity: 1, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Tea Bags', aliases: ['tea bags', 'lipton', 'tetley', 'twinings', 'chai bags'], category: 'beverage', subcategory: 'tea', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'boxes', typicalQuantity: 1, isPerishable: false, source: 'custom'),

  // --- Coffee ---
  ShelfLifeItem(name: 'Coffee Powder', aliases: ['coffee', 'filter coffee', 'bru coffee', 'nescafe', 'nescafe classic', 'bru instant', 'cothas coffee', 'narasus coffee', 'leo coffee'], category: 'beverage', subcategory: 'coffee', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 200, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Instant Coffee', aliases: ['nescafe gold', 'bru gold', 'instant coffee', 'coffee sachet'], category: 'beverage', subcategory: 'coffee', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 50, isPerishable: false, source: 'custom'),

  // --- Health Drinks ---
  ShelfLifeItem(name: 'Bournvita', aliases: ['bournvita', 'cadbury bournvita'], category: 'beverage', subcategory: 'health', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 500, brand: 'Cadbury', isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Horlicks', aliases: ['horlicks', 'junior horlicks', 'womens horlicks'], category: 'beverage', subcategory: 'health', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 500, brand: 'Horlicks', isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Complan', aliases: ['complan'], category: 'beverage', subcategory: 'health', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 500, isPerishable: false, source: 'custom'),

  // --- Juices ---
  ShelfLifeItem(name: 'Fresh Juice', aliases: ['juice', 'fresh juice', 'homemade juice'], category: 'beverage', subcategory: 'juice', shelfDaysByLocation: {'fridge': 2}, defaultLocation: 'fridge', defaultUnit: 'ml', typicalQuantity: 500, source: 'custom'),
  ShelfLifeItem(name: 'Packaged Juice', aliases: ['real juice', 'tropicana', 'paper boat', 'raw pressery', 'b natural', 'real fruit juice', 'minute maid'], category: 'beverage', subcategory: 'juice', shelfDaysByLocation: {'pantry': 270, 'fridge': 270}, defaultLocation: 'pantry', defaultUnit: 'L', typicalQuantity: 1, openedShelfDays: 5, source: 'custom'),
  ShelfLifeItem(name: 'Coconut Water', aliases: ['coconut water', 'nariyal pani', 'elaneer', 'raw pressery coconut water', 'paper boat coconut water'], category: 'beverage', subcategory: 'juice', shelfDaysByLocation: {'fridge': 3}, defaultLocation: 'fridge', defaultUnit: 'ml', typicalQuantity: 200, source: 'custom'),
  ShelfLifeItem(name: 'Tang', aliases: ['tang', 'tang orange', 'rasna', 'instant drink mix'], category: 'beverage', subcategory: 'juice', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 500, isPerishable: false, source: 'custom'),

  // --- Packaged drinks ---
  ShelfLifeItem(name: 'Buttermilk Packet', aliases: ['nandini majjige', 'amul chaas', 'amul masti buttermilk', 'packaged chaas'], category: 'beverage', subcategory: 'dairy', shelfDaysByLocation: {'fridge': 7}, defaultLocation: 'fridge', defaultUnit: 'ml', typicalQuantity: 200, source: 'custom'),
  ShelfLifeItem(name: 'Packaged Lassi', aliases: ['amul lassi', 'nandini lassi', 'lassi packet'], category: 'beverage', subcategory: 'dairy', shelfDaysByLocation: {'fridge': 10}, defaultLocation: 'fridge', defaultUnit: 'ml', typicalQuantity: 200, source: 'custom'),
  ShelfLifeItem(name: 'Soda Water', aliases: ['soda', 'sparkling water', 'club soda', 'tonic water'], category: 'beverage', subcategory: 'other', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'bottles', typicalQuantity: 1, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Squash', aliases: ['squash', 'rooh afza', 'mapro', 'lemon squash', 'orange squash', 'kissan squash'], category: 'beverage', subcategory: 'other', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'bottles', typicalQuantity: 1, isPerishable: false, openedShelfDays: 30, source: 'custom'),
];
