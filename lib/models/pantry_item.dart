
class PantryItem {
  final String? id;
  final String userId;
  final String name;
  final String? category;
  final String? quantity;
  final String? unit;
  final DateTime? expirationDate;

  PantryItem({
    this.id,
    required this.userId,
    required this.name,
    this.category,
    this.quantity,
    this.unit,
    this.expirationDate,
  });

  factory PantryItem.fromMap(Map<String, dynamic> map) {
    return PantryItem(
      id: map['id'] as String?, 
      userId: map['user_id'] as String,
      name: map['name'] as String,
      category: map['category'] as String?,
      quantity: map['quantity'] as String?,
      unit: map['unit'] as String?,
      expirationDate: map['expiration_date'] != null
          ? DateTime.parse(map['expiration_date'] as String)
          : null,
    );
  }

 Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiration_date': expirationDate?.toIso8601String(),
    };

    if (id != null && id!.isNotEmpty) {
      map['id'] = id;
    }

    return map;
  }
}
