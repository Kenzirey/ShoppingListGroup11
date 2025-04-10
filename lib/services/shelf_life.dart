/// The shelf life of each item in days.
class ShelfLife {
  static const Map<String, int> shelfLifeByItem = {
    // Dairy
    'milk': 9,
    'cheese': 20,
    'yogurt': 14,
    'cream': 7,
    'butter': 30,

    // Bakery
    'bread': 7,
    'rolls': 5,
    'baguette': 3,

    // Fruits
    'apples': 14,
    'bananas': 5,
    'oranges': 14,
    'grapes': 7,

    // Vegetables
    'lettuce': 5,
    'carrots': 14,
    'cucumber': 7,
    'tomatoes': 7,
    'onions': 30,
    'potatoes': 21,

    // Meat
    'chicken': 2,
    'beef': 4,
    'pork': 3,
    'ham': 5,
    'bacon': 7,

    // Packaged/Processed
    'pasta': 730,
    'rice': 730,
    'cereal': 180,
    'cookies': 60,
    'juice': 7,
    'eggs': 21,
  };

  static const int defaultShelfLife = 7;

  /// Returns the shelf life of the given item.
  static int getShelfLife(String itemName) {
    final lower = itemName.toLowerCase();
    return shelfLifeByItem[lower] ?? defaultShelfLife;
  }
}
