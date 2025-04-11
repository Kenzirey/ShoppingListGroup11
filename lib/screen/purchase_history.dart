import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopping_list_g11/data/dummy_purchase_history_data.dart';
import 'package:shopping_list_g11/widget/search_bar.dart';
import '../models/product.dart';
import '../data/measurement_type.dart';

/// Screen that shows the purchase history of the user.
/// Allows user to add a new product with price, amount and date.
class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  // The full list from dummy data, sorted in descending order (latest first).
  late List<Product> sortedProducts;
  // The list currently displayed (page by page).
  List<Product> displayedProducts = [];
  // Lazy loading parameters.
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;

  late String selectedMonth;

  @override
  void initState() {
    super.initState();
    // Set the selected month initially.
    selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());

    // Create a sorted copy (descending by purchase date).
    sortedProducts = List<Product>.from(dummyProducts)
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
    // Load the initial page.
    _fetchMoreProducts();
  }

  // Fetch the next page of products from sortedProducts.
  Future<void> _fetchMoreProducts() async {
    if (_isLoading) return;
    if (_currentPage * _pageSize >= sortedProducts.length) return;

    setState(() {
      _isLoading = true;
    });
    // Adjust the delay if you need a snappier load.
    await Future.delayed(const Duration(milliseconds: 800));

    final int start = _currentPage * _pageSize;
    int end = (_currentPage + 1) * _pageSize;
    if (end > sortedProducts.length) {
      end = sortedProducts.length;
    }
    setState(() {
      displayedProducts.addAll(sortedProducts.sublist(start, end));
      _currentPage++;
      _isLoading = false;
    });
  }

  /// Returns all the unique months from the provided list.
  Set<String> getAvailableMonths(List<Product> prods) {
    final Set<String> months = prods
        .map((product) => DateFormat('MMMM yyyy').format(product.purchaseDate))
        .toSet();
    // Always include the current month.
    months.add(DateFormat('MMMM yyyy').format(DateTime.now()));
    return months;
  }

  /// Filters products to only those matching the selected month.
  List<Product> getProductsForSelectedMonth(List<Product> prods) {
    return prods.where((product) {
      final productMonth = DateFormat('MMMM yyyy').format(product.purchaseDate);
      return productMonth == selectedMonth;
    }).toList();
  }

  /// Groups products by day ("dd MMM, yyyy").
  Map<String, List<Product>> groupProductsByDay(List<Product> prods) {
    final Map<String, List<Product>> grouped = {};
    final dayFormat = DateFormat('dd MMM, yyyy');
    for (final product in prods) {
      final dayKey = dayFormat.format(product.purchaseDate);
      grouped.putIfAbsent(dayKey, () => []).add(product);
    }
    return grouped;
  }

  /// Let the user pick a date, then prompt for price & amount, then create a new product.
  Future<void> handleAddItem(String itemName) async {
    final chosenDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (chosenDate == null) return;

    final userInputs = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        String enteredPrice = '';
        String enteredAmount = '';
        return AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surface,
          title: Text(
            'Enter Price & Amount',
            style: TextStyle(
              color: Theme.of(ctx).colorScheme.tertiary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: TextStyle(color: Theme.of(ctx).colorScheme.tertiary),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price (kr)',
                  labelStyle:
                      TextStyle(color: Theme.of(ctx).colorScheme.tertiary),
                  hintText: 'e.g. 49.99',
                  hintStyle: TextStyle(
                    color: Theme.of(ctx).colorScheme.tertiary.withOpacity(0.6),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(ctx).colorScheme.tertiary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(ctx).colorScheme.tertiary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (val) => enteredPrice = val,
              ),
              const SizedBox(height: 12),
              TextField(
                style: TextStyle(color: Theme.of(ctx).colorScheme.tertiary),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle:
                      TextStyle(color: Theme.of(ctx).colorScheme.tertiary),
                  hintText: 'e.g. 2.5',
                  hintStyle: TextStyle(
                    color: Theme.of(ctx).colorScheme.tertiary.withOpacity(0.6),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(ctx).colorScheme.tertiary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(ctx).colorScheme.tertiary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (val) => enteredAmount = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(ctx).colorScheme.tertiary),
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(ctx).colorScheme.tertiary),
              onPressed: () {
                Navigator.of(ctx).pop({
                  'price': enteredPrice,
                  'amount': enteredAmount,
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (userInputs == null) return;
    final price = userInputs['price'] ?? '';
    final amount = userInputs['amount'] ?? '';
    if (price.isEmpty || amount.isEmpty) return;

    final newProduct = Product.fromName(
      name: itemName,
      purchaseDate: chosenDate,
      price: price,
      amount: amount,
    );

    // When adding a new product, add it to the full list and rebuild to make it appear.
    setState(() {
      sortedProducts.add(newProduct);
      sortedProducts.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      final int itemsToShow = _currentPage * _pageSize;
      displayedProducts = sortedProducts.take(itemsToShow).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter the currently displayed products by selected month.
    final monthProducts = getProductsForSelectedMonth(displayedProducts);
    // Sort descending.
    final groupedByDay = groupProductsByDay(monthProducts);
    final dayFormat = DateFormat('dd MMM, yyyy');
    final sortedDayKeys = groupedByDay.keys.toList()
      ..sort((a, b) => dayFormat.parse(b).compareTo(dayFormat.parse(a)));

    final mapSuggestions = groceryMapping.keys.toList()..sort();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // search bar at the very top, reusable widget
            CustomSearchBarWidget(
              suggestions: mapSuggestions,
              onSuggestionSelected: (itemName) => handleAddItem(itemName),
              hintText: 'Add product to purchase history...',
            ),
            const SizedBox(height: 16),
            // Purchase history title + dropdown for month selection.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Purchase History",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                DropdownButton<String>(
                  value: selectedMonth,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  items: getAvailableMonths(displayedProducts).map((month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(
                        month,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newMonth) {
                    if (newMonth != null) {
                      setState(() {
                        selectedMonth = newMonth;
                      });
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            // Scrollable list with "lazy" loading.
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (!_isLoading &&
                      scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent) {
                    _fetchMoreProducts();
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: sortedDayKeys.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == sortedDayKeys.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final dayKey = sortedDayKeys[index];
                    final dayProducts = groupedByDay[dayKey] ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            dayKey,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                        ...dayProducts.map((product) {
                          final unitLabel =
                              getUnitLabel(product.measurementType);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_grocery_store,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Amount: ${product.amount} $unitLabel',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${product.price} kr',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
