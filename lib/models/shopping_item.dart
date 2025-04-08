
class ShoppingItem {
  final String? id;
  final String userId;
  final String itemName;
  final String? quantity;
  final String? category;

  ShoppingItem({
    this.id,
    required this.userId,
    required this.itemName,
    this.quantity,
    this.category,
  });

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      itemName: map['item_name'] as String,
      quantity: map['quantity'] as String?,
      category: map['category'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'item_name': itemName,
      'quantity': quantity,
      'category': category,
      if (id != null && id!.isNotEmpty) 'id': id,
    };
  }
}
