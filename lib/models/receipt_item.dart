/// ReceiptItem model class
class ReceiptItem {
  String name;
  double quantity;
  double price;
  String? allergy;
  String unit;
  DateTime? expirationDate;
  String category;

  ReceiptItem({
    required this.name,
    this.quantity = 1.0,
    required this.price,
    this.allergy,
    this.unit = '',
    this.expirationDate,
    required this.category,
  });

  double get totalPrice => quantity * price;

  @override
  String toString() =>
      'ReceiptItem(name: $name, quantity: $quantity, unitPrice: $price, allergy: $allergy ' "expirationDate: $expirationDate"
          ')';
}
