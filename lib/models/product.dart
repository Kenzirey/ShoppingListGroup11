import 'package:shopping_list_g11/data/measurement_type.dart';

/// Represents one grocery item product.
class Product {
  final String name;
  final MeasurementType? measurementType;
  final DateTime purchaseDate;
  final String? price;
  final String amount;

  const Product({
    required this.name,
    this.measurementType,
    required this.purchaseDate,
    this.price,
    required this.amount,
  });

  /// Factory constructor with optional [measurementType].

  factory Product.fromName({
    required String name,
    required DateTime purchaseDate,
    String? price,
    required String amount,
    MeasurementType? measurementType,
  }) {
    return Product(
      name: name,
      measurementType: measurementType,
      purchaseDate: purchaseDate,
      price: price,
      amount: amount,
    );
  }
}




// In regard to dietary things, it should probably be a tag on the product itself in database, so when OCR finds lactose free milk,
// it adds a tag on it to indicate it is lactose free. But the name just remains "milk" not "lactose free milk"

// changing from specific brand names to just milk etc is called normalize, and adding attributes is probably better longterm?