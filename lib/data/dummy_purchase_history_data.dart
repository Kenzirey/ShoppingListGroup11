import 'package:shopping_list_g11/models/product.dart';


// Dummy data for testing features and developing UI of the purchase history screen.
final List<Product> dummyProducts = [
  // Generate 30+ products for April (e.g., "Banana")
  ...List.generate(
    30,
    (index) => Product.fromName(
      name: 'Banana ${index + 1}',
      purchaseDate: DateTime(2025, 4, (index % 30) + 1), // Days 1-30 in April
      price: '${5 + index}', // Vary price slightly for variety
      amount: '5',
    ),
  ),
  // Some additional dummy products for other months
  Product.fromName(
      name: 'Apple',
      purchaseDate: DateTime(2025, 3, 25),
      price: '10',
      amount: '3'),
        Product.fromName(
      name: 'sad',
      purchaseDate: DateTime(2025, 4, 1),
      price: '10',
      amount: '3'),
              Product.fromName(
      name: 'Big Sad',
      purchaseDate: DateTime(2025, 4, 30),
      price: '999',
      amount: '99'),
              Product.fromName(
      name: 'Pikachu',
      purchaseDate: DateTime(2025, 4, 30),
      price: '666',
      amount: '1'),
        Product.fromName(
      name: 'Psyduck',
      purchaseDate: DateTime(2025, 4, 1),
      price: '10',
      amount: '3'),
  Product.fromName(
      name: 'Milk',
      purchaseDate: DateTime(2025, 2, 28),
      price: '12',
      amount: '1'),
  Product.fromName(
      name: 'Eggs',
      purchaseDate: DateTime(2025, 1, 15),
      price: '20',
      amount: '12'),
];