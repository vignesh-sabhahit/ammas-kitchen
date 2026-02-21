import 'shelf_life_data.dart';

/// ~50 Packaged Food items with brand aliases
final List<ShelfLifeItem> packagedItems = [
  // --- Instant Food ---
  ShelfLifeItem(name: 'Maggi Noodles', aliases: ['maggi', 'maggi 2 minute', 'maggi masala noodles', 'maggi noodles'], category: 'packaged', subcategory: 'instant', shelfDaysByLocation: {'pantry': 270}, defaultLocation: 'pantry', defaultUnit: 'packets', typicalQuantity: 4, brand: 'Maggi', isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Yippee Noodles', aliases: ['yippee', 'sunfeast yippee', 'yippee noodles', 'yippee magic masala'], category: 'packaged', subcategory: 'instant', shelfDaysByLocation: {'pantry': 270}, defaultLocation: 'pantry', defaultUnit: 'packets', typicalQuantity: 4, brand: 'ITC', isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Top Ramen', aliases: ['top ramen', 'nissin', 'cup noodles'], category: 'packaged', subcategory: 'instant', shelfDaysByLocation: {'pantry': 270}, defaultLocation: 'pantry', defaultUnit: 'packets', typicalQuantity: 4, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'MTR Ready to Eat', aliases: ['mtr ready to eat', 'mtr dal fry', 'mtr palak paneer', 'mtr rajma masala', 'mtr biryani', 'mtr rava idli mix', 'mtr bisibele bath'], category: 'packaged', subcategory: 'instant', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'packets', typicalQuantity: 1, brand: 'MTR', isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Haldiram Ready Meal', aliases: ['haldiram', 'haldirams', 'haldiram minute khana', 'haldiram ready to eat'], category: 'packaged', subcategory: 'instant', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'packets', typicalQuantity: 1, brand: 'Haldiram', isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Instant Mix', aliases: ['mtr instant mix', 'mtr rava idli', 'mtr dosa mix', 'mtr gulab jamun mix', 'gits', 'gits mix'], category: 'packaged', subcategory: 'instant', shelfDaysByLocation: {'pantry': 270}, defaultLocation: 'pantry', defaultUnit: 'packets', typicalQuantity: 1, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Cup Noodles', aliases: ['cup noodles', 'nissin cup noodles', 'wai wai'], category: 'packaged', subcategory: 'instant', shelfDaysByLocation: {'pantry': 270}, defaultLocation: 'pantry', defaultUnit: 'pieces', typicalQuantity: 2, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Instant Upma Mix', aliases: ['mtr upma', 'upma mix', 'instant upma', 'mtr khara bath'], category: 'packaged', subcategory: 'instant', shelfDaysByLocation: {'pantry': 270}, defaultLocation: 'pantry', defaultUnit: 'packets', typicalQuantity: 1, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Instant Poha Mix', aliases: ['mtr poha', 'poha mix', 'instant poha'], category: 'packaged', subcategory: 'instant', shelfDaysByLocation: {'pantry': 270}, defaultLocation: 'pantry', defaultUnit: 'packets', typicalQuantity: 1, isPerishable: false, source: 'custom'),

  // --- Breakfast Cereals ---
  ShelfLifeItem(name: 'Cornflakes', aliases: ['corn flakes', 'kelloggs corn flakes', 'kelloggs', 'kellogg', 'chocos', 'bagrry'], category: 'packaged', subcategory: 'cereal', shelfDaysByLocation: {'pantry': 270}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 500, isPerishable: false, openedShelfDays: 30, source: 'custom'),
  ShelfLifeItem(name: 'Muesli', aliases: ['muesli', 'bagrry muesli', 'kelloggs muesli', 'yogabar muesli', 'granola'], category: 'packaged', subcategory: 'cereal', shelfDaysByLocation: {'pantry': 180}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 500, isPerishable: false, openedShelfDays: 30, source: 'custom'),
  ShelfLifeItem(name: 'Oats', aliases: ['quaker oats', 'saffola oats', 'kelloggs oats', 'instant oats', 'rolled oats', 'masala oats'], category: 'packaged', subcategory: 'cereal', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 500, isPerishable: false, source: 'custom'),

  // --- Spreads & Dips ---
  ShelfLifeItem(name: 'Nutella', aliases: ['nutella', 'chocolate spread', 'hazelnut spread'], category: 'packaged', subcategory: 'spread', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 350, brand: 'Nutella', openedShelfDays: 60, source: 'custom'),

  // --- Canned/Tetra pack ---
  ShelfLifeItem(name: 'Canned Beans', aliases: ['rajma can', 'canned chickpeas', 'del monte beans', 'canned baked beans'], category: 'packaged', subcategory: 'canned', shelfDaysByLocation: {'pantry': 730}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 400, isPerishable: false, openedShelfDays: 3, source: 'custom'),
  ShelfLifeItem(name: 'Canned Corn', aliases: ['sweet corn can', 'del monte sweet corn', 'del monte corn'], category: 'packaged', subcategory: 'canned', shelfDaysByLocation: {'pantry': 730}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 400, brand: 'Del Monte', isPerishable: false, openedShelfDays: 3, source: 'custom'),
  ShelfLifeItem(name: 'Canned Tomato', aliases: ['tomato puree', 'tomato paste', 'del monte tomato', 'canned tomato', 'passata'], category: 'packaged', subcategory: 'canned', shelfDaysByLocation: {'pantry': 730}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 400, isPerishable: false, openedShelfDays: 5, source: 'custom'),
  ShelfLifeItem(name: 'Coconut Milk', aliases: ['coconut milk', 'coconut cream', 'canned coconut milk'], category: 'packaged', subcategory: 'canned', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'ml', typicalQuantity: 400, isPerishable: false, openedShelfDays: 3, source: 'custom'),

  // --- Dosa/Idli Batter ---
  ShelfLifeItem(name: 'Dosa Batter', aliases: ['dosa batter', 'idli dosa batter', 'maiyas dosa batter', 'a2b batter', 'store bought batter', 'id fresh batter', 'id batter'], category: 'packaged', subcategory: 'fresh', shelfDaysByLocation: {'fridge': 5}, defaultLocation: 'fridge', defaultUnit: 'kg', typicalQuantity: 1, source: 'custom'),
  ShelfLifeItem(name: 'Idli Batter', aliases: ['idli batter', 'idli dosa batter'], category: 'packaged', subcategory: 'fresh', shelfDaysByLocation: {'fridge': 5}, defaultLocation: 'fridge', defaultUnit: 'kg', typicalQuantity: 1, source: 'custom'),

  // --- Cooking aids ---
  ShelfLifeItem(name: 'Baking Powder', aliases: ['baking powder', 'weikfield baking powder'], category: 'packaged', subcategory: 'baking', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 100, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Baking Soda', aliases: ['baking soda', 'meetha soda', 'sodium bicarbonate', 'cooking soda'], category: 'packaged', subcategory: 'baking', shelfDaysByLocation: {'pantry': 730}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 100, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Yeast', aliases: ['dry yeast', 'active dry yeast', 'instant yeast'], category: 'packaged', subcategory: 'baking', shelfDaysByLocation: {'pantry': 365, 'fridge': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 100, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Vanilla Essence', aliases: ['vanilla extract', 'vanilla essence', 'vanilla flavouring'], category: 'packaged', subcategory: 'baking', shelfDaysByLocation: {'pantry': 730}, defaultLocation: 'pantry', defaultUnit: 'ml', typicalQuantity: 25, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Food Colour', aliases: ['food colour', 'food coloring', 'food dye'], category: 'packaged', subcategory: 'baking', shelfDaysByLocation: {'pantry': 730}, defaultLocation: 'pantry', defaultUnit: 'ml', typicalQuantity: 20, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Cocoa Powder', aliases: ['cocoa powder', 'cadbury cocoa', 'baking cocoa'], category: 'packaged', subcategory: 'baking', shelfDaysByLocation: {'pantry': 730}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 100, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Custard Powder', aliases: ['custard powder', 'weikfield custard'], category: 'packaged', subcategory: 'baking', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 100, isPerishable: false, source: 'custom'),
  ShelfLifeItem(name: 'Jello', aliases: ['jelly', 'jelly crystals', 'weikfield jelly', 'jello'], category: 'packaged', subcategory: 'baking', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'packets', typicalQuantity: 1, isPerishable: false, source: 'custom'),

  // --- Health food ---
  ShelfLifeItem(name: 'Protein Powder', aliases: ['whey protein', 'protein powder', 'protinex', 'ensure'], category: 'packaged', subcategory: 'health', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 500, isPerishable: false, openedShelfDays: 60, source: 'custom'),
  ShelfLifeItem(name: 'Chyawanprash', aliases: ['chyawanprash', 'dabur chyawanprash', 'patanjali chyawanprash'], category: 'packaged', subcategory: 'health', shelfDaysByLocation: {'pantry': 365}, defaultLocation: 'pantry', defaultUnit: 'g', typicalQuantity: 500, brand: 'Dabur', isPerishable: false, source: 'custom'),

  // --- Incense & Non-food (bonus) ---
  ShelfLifeItem(name: 'Incense', aliases: ['agarbatti', 'incense sticks', 'dhoop', 'phool incense', 'cycle agarbatti', 'zed black'], category: 'other', subcategory: 'non-food', shelfDaysByLocation: {'pantry': 730}, defaultLocation: 'shelf', defaultUnit: 'packets', typicalQuantity: 1, isPerishable: false, source: 'custom'),
];
