/// ReceiptItem model class
class ReceiptItem {
  String name;
  int quantity;
  double price;
  String? allergy;

  ReceiptItem({
    required this.name,
    this.quantity = 1,
    required this.price,
    this.allergy,
  });

  double get totalPrice => quantity * price;

  @override
  String toString() =>
      'ReceiptItem(name: $name, quantity: $quantity, unitPrice: $price, allergy: $allergy)';
}
