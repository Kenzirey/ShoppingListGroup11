/// Represents one grocery item product.
class Product {
  final String name;
  final DateTime purchaseDate;
  final String? price;
  final String amount;
  final String? category;

  const Product({
    required this.name,
    required this.purchaseDate,
    this.price,
    required this.amount,
    this.category,
  });

  /// Factory constructor with optional [measurementType].

  factory Product.fromName({
    required String name,
    required DateTime purchaseDate,
    String? price,
    required String amount,
    String? category,
  }) {
    return Product(
      name: name,
      purchaseDate: purchaseDate,
      price: price,
      amount: amount,
      category: category,
    );
  }
}