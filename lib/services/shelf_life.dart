/// The shelf life of each item in days.
class ShelfLife {
  static const Map<String, int> shelfLifeByItem = {
    'milk': 9,
    'cheese': 20,
    'yogurt': 14,
    'bread': 7,
    'apples': 14,
    'bananas': 5,
    'chicken': 2,
    'beef': 4,
    'fish': 4,
    'lettuce': 5,
    'carrots': 14,
  };

  static const int defaultShelfLife = 7;

  /// Returns the shelf life of the given item.
  static int getShelfLife(String itemName) {
    final lower = itemName.toLowerCase();
    return shelfLifeByItem[lower] ?? defaultShelfLife;
  }
}
