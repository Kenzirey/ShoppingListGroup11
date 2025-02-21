/// ReceiptItem model class
class ReceiptItem {
  String name;
  double price;
  String? allergy;

  ReceiptItem({
    required this.name,
    required this.price,
    this.allergy,
  });

  @override
  String toString() => 'ReceiptItem(name: $name, price: $price, allergy: $allergy)';
}