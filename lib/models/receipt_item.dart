/// ReceiptItem model class
class ReceiptItem {
  String name;
  int quantity;
  double price;
  String? allergy;
  String unit;

  ReceiptItem({
    required this.name,
    this.quantity = 1,
    required this.price,
    this.allergy,
    this.unit = '',
  });

  double get totalPrice => quantity * price;

  @override
  String toString() =>
      'ReceiptItem(name: $name, quantity: $quantity, unitPrice: $price, allergy: $allergy)';
}
