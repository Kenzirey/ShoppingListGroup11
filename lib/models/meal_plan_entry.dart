class MealPlanEntry {
  final String id;
  final String userId;
  final int week;
  final String day;
  final String name;
  final String? description;
  final int servings;
  final bool lactoseFree;
  final bool vegan;
  final bool vegetarian;

  final DateTime createdAt;

  MealPlanEntry({
    required this.id,
    required this.userId,
    required this.week,
    required this.day,
    required this.name,
    this.description,
    this.servings = 1,
    this.lactoseFree = false,
    this.vegan = false,
    this.vegetarian = false,
    required this.createdAt,
  });

  factory MealPlanEntry.fromMap(Map<String, dynamic> m) => MealPlanEntry(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        week: m['week'] as int,
        day: m['day'] as String,
        name: m['name'] as String,
        description: m['description'] as String?,
        servings: (m['servings'] as int?) ?? 1,
        lactoseFree: (m['lactose_free'] as bool?) ?? false,
        vegan: (m['vegan'] as bool?) ?? false,
        vegetarian: (m['vegetarian'] as bool?) ?? false,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'week': week,
        'day': day,
        'name': name,
        if (description != null) 'description': description,
        'servings': servings,
        'lactose_free': lactoseFree,
        'vegan': vegan,
        'vegetarian': vegetarian,
      };
}
