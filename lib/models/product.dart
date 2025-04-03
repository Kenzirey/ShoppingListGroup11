import 'package:shopping_list_g11/data/measurement_type.dart';

/// Represents one grocery item product.
class Product {
  final String name;
  final MeasurementType measurementType;
  final DateTime purchaseDate;
  final String? price;
  final String amount;

  Product({
    required this.name,
    required this.measurementType,
    required this.purchaseDate,
    this.price,
    required this.amount,
  });

  // Factory constructor that uses the mapping to determine measurementType.
  factory Product.fromName({
    required String name,
    required DateTime purchaseDate,
    price,
    required String amount,
  }) {
    final normalized = name.toLowerCase().trim();
    final type = groceryMapping[normalized] ?? MeasurementType.amount;
    return Product(
      name: name,
      measurementType: type,
      purchaseDate: purchaseDate,
      price: price,
      amount: amount,
    );
  }
}



// In regard to dietary things, it should probably be a tag on the product itself in database, so when OCR finds lactose free milk,
// it adds a tag on it to indicate it is lactose free. But the name just remains "milk" not "lactose free milk"

// changing from specific brand names to just milk etc is called normalize, and adding attributes is probably better longterm?