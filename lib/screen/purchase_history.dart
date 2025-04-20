import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shopping_list_g11/data/dummy_purchase_history_data.dart';
import 'package:shopping_list_g11/utils/month_day_util.dart';
import 'package:shopping_list_g11/widget/search_bar.dart';
import '../models/product.dart';
import '../data/measurement_type.dart';

/// Screen that shows the purchase history of the user.
/// Allows user to add a new product with price, amount, date, and optional unit.
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

  // The currently selected month.
  late String selectedMonth;

  @override
  void initState() {
    super.initState();
    // Set the selected month initially to the current month.
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

    setState(() => _isLoading = true);

    final int start = _currentPage * _pageSize;
    int end = (_currentPage + 1) * _pageSize;
    if (end > sortedProducts.length) end = sortedProducts.length;

    setState(() {
      displayedProducts.addAll(sortedProducts.sublist(start, end));
      _currentPage++;
      _isLoading = false;
    });
  }

  /// Let the user pick a date, then prompt for price, amount, and optional unit, then create a new product.
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
        String? selectedUnit;
        const unitOptions = ['kg', 'g', 'l', 'ml'];
        return AlertDialog(
          backgroundColor: Theme.of(ctx).colorScheme.surface,
          title: Text(
            'Enter Price, Amount & Unit',
            style: TextStyle(
              color: Theme.of(ctx).colorScheme.tertiary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: StatefulBuilder(
            builder: (ctx2, setMb) {
              return Column(
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
                          color: Theme.of(ctx)
                              .colorScheme
                              .tertiary
                              .withOpacity(0.6)),
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
                          color: Theme.of(ctx)
                              .colorScheme
                              .tertiary
                              .withOpacity(0.6)),
                    ),
                    onChanged: (val) => enteredAmount = val,
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    hint: Text('Unit',
                        style: TextStyle(
                            color: Theme.of(ctx).colorScheme.tertiary)),
                    value: selectedUnit,
                    items: unitOptions.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit,
                            style: TextStyle(
                                color: Theme.of(ctx).colorScheme.tertiary)),
                      );
                    }).toList(),
                    selectedItemBuilder: (_) => unitOptions.map((unit) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          unit,
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(ctx).colorScheme.tertiary),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setMb(() => selectedUnit = val),
                  ),
                ],
              );
            },
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
              onPressed: () => Navigator.of(ctx).pop({
                'price': enteredPrice,
                'amount': enteredAmount,
                'unit': selectedUnit ?? '',
              }),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (userInputs == null) return;
    final price = userInputs['price']!;
    final amount = userInputs['amount']!;
    final unit = userInputs['unit'] ?? '';
    if (price.isEmpty || amount.isEmpty) return;

    final amountText = unit.isEmpty ? amount : '$amount $unit';
    final newProduct = Product.fromName(
      name: itemName,
      purchaseDate: chosenDate,
      price: price,
      amount: amountText,
    );

    setState(() {
      sortedProducts.add(newProduct);
      sortedProducts.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      final int itemsToShow = _currentPage * _pageSize;
      displayedProducts = sortedProducts.take(itemsToShow).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthProducts = MonthAndDayUtility.getProductsForSelectedMonth(
        displayedProducts, selectedMonth);
    final groupedByDay = MonthAndDayUtility.groupProductsByDay(monthProducts);
    final sortedDayKeys = groupedByDay.keys.toList()
      ..sort((a, b) => DateFormat('dd MMM, yyyy')
          .parse(b)
          .compareTo(DateFormat('dd MMM, yyyy').parse(a)));

    final mapSuggestions = groceryMapping.keys.toList()..sort();
    final months = MonthAndDayUtility.getMonthsUpToCurrent();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSearchBarWidget(
              suggestions: mapSuggestions,
              onSuggestionSelected: handleAddItem,
              hintText: 'Add product to purchase history...',
            ),
            const SizedBox(height: 16),
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
                  items: months.map((month) {
                    final isCurrent = month == months.last;
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(
                        month,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isCurrent
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return months.map((month) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          month,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  onChanged: (newMonth) {
                    if (newMonth != null) {
                      setState(() => selectedMonth = newMonth);
                    }
                  },
                ),
              ],
            ),
            const Divider(),
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
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
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
                                        'Amount: ${product.amount}',
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
