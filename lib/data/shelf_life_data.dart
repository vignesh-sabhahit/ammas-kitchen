/// Default shelf life data for common Indian grocery items.
/// Each entry: item_name, category, location (fridge/pantry/freezer), shelf_days, source
final List<Map<String, dynamic>> shelfLifeDefaults = [
  // === VEGETABLES ===
  {'item_name': 'Tomato', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 7, 'source': 'custom'},
  {'item_name': 'Tomato', 'category': 'vegetable', 'location': 'pantry', 'shelf_days': 3, 'source': 'custom'},
  {'item_name': 'Onion', 'category': 'vegetable', 'location': 'pantry', 'shelf_days': 30, 'source': 'usda'},
  {'item_name': 'Potato', 'category': 'vegetable', 'location': 'pantry', 'shelf_days': 21, 'source': 'usda'},
  {'item_name': 'Carrot', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 14, 'source': 'usda'},
  {'item_name': 'Beans', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 5, 'source': 'custom'},
  {'item_name': 'Capsicum', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 7, 'source': 'custom'},
  {'item_name': 'Brinjal', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 5, 'source': 'custom'},
  {'item_name': 'Cauliflower', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 7, 'source': 'usda'},
  {'item_name': 'Cabbage', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 14, 'source': 'usda'},
  {'item_name': 'Spinach', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 5, 'source': 'usda'},
  {'item_name': 'Methi', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 4, 'source': 'custom'},
  {'item_name': 'Coriander', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 7, 'source': 'custom'},
  {'item_name': 'Curry Leaves', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 10, 'source': 'custom'},
  {'item_name': 'Green Chilli', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 10, 'source': 'custom'},
  {'item_name': 'Ginger', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 21, 'source': 'usda'},
  {'item_name': 'Garlic', 'category': 'vegetable', 'location': 'pantry', 'shelf_days': 30, 'source': 'usda'},
  {'item_name': 'Drumstick', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 5, 'source': 'custom'},
  {'item_name': 'Bitter Gourd', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 5, 'source': 'custom'},
  {'item_name': 'Bottle Gourd', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 7, 'source': 'custom'},
  {'item_name': 'Ridge Gourd', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 5, 'source': 'custom'},
  {'item_name': 'Ladies Finger', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 4, 'source': 'custom'},
  {'item_name': 'Beetroot', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 14, 'source': 'usda'},
  {'item_name': 'Radish', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 10, 'source': 'usda'},
  {'item_name': 'Peas', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 5, 'source': 'custom'},
  {'item_name': 'Sweet Potato', 'category': 'vegetable', 'location': 'pantry', 'shelf_days': 14, 'source': 'usda'},
  {'item_name': 'Mushroom', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 5, 'source': 'usda'},

  // === FRUITS ===
  {'item_name': 'Banana', 'category': 'fruit', 'location': 'pantry', 'shelf_days': 5, 'source': 'usda'},
  {'item_name': 'Apple', 'category': 'fruit', 'location': 'fridge', 'shelf_days': 21, 'source': 'usda'},
  {'item_name': 'Mango', 'category': 'fruit', 'location': 'pantry', 'shelf_days': 5, 'source': 'custom'},
  {'item_name': 'Mango', 'category': 'fruit', 'location': 'fridge', 'shelf_days': 10, 'source': 'custom'},
  {'item_name': 'Papaya', 'category': 'fruit', 'location': 'fridge', 'shelf_days': 5, 'source': 'custom'},
  {'item_name': 'Grapes', 'category': 'fruit', 'location': 'fridge', 'shelf_days': 7, 'source': 'usda'},
  {'item_name': 'Orange', 'category': 'fruit', 'location': 'fridge', 'shelf_days': 14, 'source': 'usda'},
  {'item_name': 'Pomegranate', 'category': 'fruit', 'location': 'fridge', 'shelf_days': 14, 'source': 'custom'},
  {'item_name': 'Guava', 'category': 'fruit', 'location': 'fridge', 'shelf_days': 5, 'source': 'custom'},
  {'item_name': 'Coconut', 'category': 'fruit', 'location': 'fridge', 'shelf_days': 14, 'source': 'custom'},
  {'item_name': 'Lemon', 'category': 'fruit', 'location': 'fridge', 'shelf_days': 21, 'source': 'usda'},
  {'item_name': 'Watermelon', 'category': 'fruit', 'location': 'fridge', 'shelf_days': 5, 'source': 'usda'},
  {'item_name': 'Sapota', 'category': 'fruit', 'location': 'fridge', 'shelf_days': 5, 'source': 'custom'},

  // === DAIRY ===
  {'item_name': 'Milk', 'category': 'dairy', 'location': 'fridge', 'shelf_days': 4, 'source': 'usda'},
  {'item_name': 'Curd', 'category': 'dairy', 'location': 'fridge', 'shelf_days': 7, 'source': 'custom'},
  {'item_name': 'Paneer', 'category': 'dairy', 'location': 'fridge', 'shelf_days': 4, 'source': 'custom'},
  {'item_name': 'Paneer', 'category': 'dairy', 'location': 'freezer', 'shelf_days': 60, 'source': 'custom'},
  {'item_name': 'Butter', 'category': 'dairy', 'location': 'fridge', 'shelf_days': 30, 'source': 'usda'},
  {'item_name': 'Cheese', 'category': 'dairy', 'location': 'fridge', 'shelf_days': 21, 'source': 'usda'},
  {'item_name': 'Ghee', 'category': 'dairy', 'location': 'pantry', 'shelf_days': 180, 'source': 'custom'},
  {'item_name': 'Cream', 'category': 'dairy', 'location': 'fridge', 'shelf_days': 7, 'source': 'usda'},
  {'item_name': 'Buttermilk', 'category': 'dairy', 'location': 'fridge', 'shelf_days': 3, 'source': 'custom'},

  // === GRAINS & PULSES ===
  {'item_name': 'Rice', 'category': 'grain', 'location': 'pantry', 'shelf_days': 365, 'source': 'usda'},
  {'item_name': 'Wheat Flour', 'category': 'grain', 'location': 'pantry', 'shelf_days': 90, 'source': 'custom'},
  {'item_name': 'Rava', 'category': 'grain', 'location': 'pantry', 'shelf_days': 180, 'source': 'custom'},
  {'item_name': 'Poha', 'category': 'grain', 'location': 'pantry', 'shelf_days': 180, 'source': 'custom'},
  {'item_name': 'Toor Dal', 'category': 'grain', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Moong Dal', 'category': 'grain', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Chana Dal', 'category': 'grain', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Urad Dal', 'category': 'grain', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Masoor Dal', 'category': 'grain', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Rajma', 'category': 'grain', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Chana', 'category': 'grain', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Besan', 'category': 'grain', 'location': 'pantry', 'shelf_days': 180, 'source': 'custom'},
  {'item_name': 'Ragi Flour', 'category': 'grain', 'location': 'pantry', 'shelf_days': 90, 'source': 'custom'},
  {'item_name': 'Idli Rava', 'category': 'grain', 'location': 'pantry', 'shelf_days': 180, 'source': 'custom'},
  {'item_name': 'Vermicelli', 'category': 'grain', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},

  // === SPICES (long shelf life) ===
  {'item_name': 'Turmeric Powder', 'category': 'spice', 'location': 'pantry', 'shelf_days': 730, 'source': 'usda'},
  {'item_name': 'Red Chilli Powder', 'category': 'spice', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Coriander Powder', 'category': 'spice', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Cumin Seeds', 'category': 'spice', 'location': 'pantry', 'shelf_days': 730, 'source': 'usda'},
  {'item_name': 'Mustard Seeds', 'category': 'spice', 'location': 'pantry', 'shelf_days': 730, 'source': 'custom'},
  {'item_name': 'Garam Masala', 'category': 'spice', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Sambar Powder', 'category': 'spice', 'location': 'pantry', 'shelf_days': 180, 'source': 'custom'},
  {'item_name': 'Rasam Powder', 'category': 'spice', 'location': 'pantry', 'shelf_days': 180, 'source': 'custom'},
  {'item_name': 'Asafoetida', 'category': 'spice', 'location': 'pantry', 'shelf_days': 730, 'source': 'custom'},
  {'item_name': 'Black Pepper', 'category': 'spice', 'location': 'pantry', 'shelf_days': 730, 'source': 'usda'},
  {'item_name': 'Cardamom', 'category': 'spice', 'location': 'pantry', 'shelf_days': 730, 'source': 'custom'},
  {'item_name': 'Cloves', 'category': 'spice', 'location': 'pantry', 'shelf_days': 730, 'source': 'custom'},
  {'item_name': 'Cinnamon', 'category': 'spice', 'location': 'pantry', 'shelf_days': 730, 'source': 'usda'},
  {'item_name': 'Bay Leaf', 'category': 'spice', 'location': 'pantry', 'shelf_days': 730, 'source': 'custom'},
  {'item_name': 'Fenugreek Seeds', 'category': 'spice', 'location': 'pantry', 'shelf_days': 730, 'source': 'custom'},

  // === OILS & CONDIMENTS ===
  {'item_name': 'Cooking Oil', 'category': 'packaged', 'location': 'pantry', 'shelf_days': 365, 'source': 'usda'},
  {'item_name': 'Coconut Oil', 'category': 'packaged', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Sesame Oil', 'category': 'packaged', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Salt', 'category': 'packaged', 'location': 'pantry', 'shelf_days': 1825, 'source': 'usda'},
  {'item_name': 'Sugar', 'category': 'packaged', 'location': 'pantry', 'shelf_days': 730, 'source': 'usda'},
  {'item_name': 'Jaggery', 'category': 'packaged', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Tamarind', 'category': 'packaged', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Pickle', 'category': 'packaged', 'location': 'fridge', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Papad', 'category': 'packaged', 'location': 'pantry', 'shelf_days': 180, 'source': 'custom'},

  // === PACKAGED FOOD ===
  {'item_name': 'Bread', 'category': 'packaged', 'location': 'pantry', 'shelf_days': 5, 'source': 'usda'},
  {'item_name': 'Bread', 'category': 'packaged', 'location': 'fridge', 'shelf_days': 10, 'source': 'usda'},
  {'item_name': 'Eggs', 'category': 'dairy', 'location': 'fridge', 'shelf_days': 21, 'source': 'usda'},
  {'item_name': 'Tea Powder', 'category': 'packaged', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Coffee Powder', 'category': 'packaged', 'location': 'pantry', 'shelf_days': 365, 'source': 'custom'},
  {'item_name': 'Biscuits', 'category': 'packaged', 'location': 'pantry', 'shelf_days': 90, 'source': 'custom'},

  // === BEVERAGES ===
  {'item_name': 'Juice', 'category': 'beverage', 'location': 'fridge', 'shelf_days': 7, 'source': 'usda'},

  // === Category-level defaults (fallback) ===
  {'item_name': 'vegetable', 'category': 'vegetable', 'location': 'fridge', 'shelf_days': 5, 'source': 'default'},
  {'item_name': 'vegetable', 'category': 'vegetable', 'location': 'pantry', 'shelf_days': 3, 'source': 'default'},
  {'item_name': 'fruit', 'category': 'fruit', 'location': 'fridge', 'shelf_days': 7, 'source': 'default'},
  {'item_name': 'fruit', 'category': 'fruit', 'location': 'pantry', 'shelf_days': 4, 'source': 'default'},
  {'item_name': 'dairy', 'category': 'dairy', 'location': 'fridge', 'shelf_days': 5, 'source': 'default'},
  {'item_name': 'grain', 'category': 'grain', 'location': 'pantry', 'shelf_days': 180, 'source': 'default'},
  {'item_name': 'spice', 'category': 'spice', 'location': 'pantry', 'shelf_days': 365, 'source': 'default'},
  {'item_name': 'packaged', 'category': 'packaged', 'location': 'pantry', 'shelf_days': 90, 'source': 'default'},
  {'item_name': 'beverage', 'category': 'beverage', 'location': 'fridge', 'shelf_days': 7, 'source': 'default'},
  {'item_name': 'other', 'category': 'other', 'location': 'pantry', 'shelf_days': 30, 'source': 'default'},
];

/// Category display info
const Map<String, String> categoryIcons = {
  'vegetable': '🥬',
  'fruit': '🍎',
  'dairy': '🥛',
  'grain': '🌾',
  'spice': '🌶️',
  'packaged': '📦',
  'beverage': '🥤',
  'other': '🏷️',
};

const Map<String, String> categoryNames = {
  'vegetable': 'Vegetables',
  'fruit': 'Fruits',
  'dairy': 'Dairy',
  'grain': 'Grains & Pulses',
  'spice': 'Spices',
  'packaged': 'Packaged Food',
  'beverage': 'Beverages',
  'other': 'Other',
};

const Map<String, String> locationIcons = {
  'fridge': '❄️',
  'freezer': '🧊',
  'pantry': '🏠',
  'shelf': '📚',
  'other': '📍',
};

const List<String> storageLocations = [
  'fridge',
  'freezer',
  'pantry',
  'shelf',
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
];
