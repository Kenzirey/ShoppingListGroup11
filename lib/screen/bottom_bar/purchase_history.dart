import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shopping_list_g11/widget/styles/pantry_icons.dart';
import '../../providers/purchase_history_provider.dart';
import '../../models/product.dart';
import '../../utils/month_day_util.dart';

/// Screen that shows the purchase history of the user.
/// Allows user to add a new product with price, amount, date, and optional unit.
class PurchaseHistoryScreen extends ConsumerStatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  ConsumerState<PurchaseHistoryScreen> createState() =>
      _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends ConsumerState<PurchaseHistoryScreen> {
  List<Product> sortedProducts = [];
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
    selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());
  }

  // Fetch the next page of products from sortedProducts.
  void _fetchMoreProducts(List<Product> sortedProducts) async {
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

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(purchaseHistoryProvider);
    if (historyAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (historyAsync.hasError) {
      return Center(
        child: Text('Failed to load history: ${historyAsync.error}'),
      );
    }

    final allProducts = historyAsync.value ?? [];

    if (sortedProducts.isEmpty) {
      sortedProducts = List<Product>.from(allProducts);
      displayedProducts = [];
      _currentPage = 0;
      _fetchMoreProducts(sortedProducts);
    }

    final monthProducts = MonthAndDayUtility.getProductsForSelectedMonth(
        displayedProducts, selectedMonth);
    final groupedByDay = MonthAndDayUtility.groupProductsByDay(monthProducts);
    final sortedDayKeys = groupedByDay.keys.toList()
      ..sort((a, b) => DateFormat('dd MMM, yyyy')
          .parse(b)
          .compareTo(DateFormat('dd MMM, yyyy').parse(a)));

    final months = MonthAndDayUtility.getMonthsUpToCurrent();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  alignment: Alignment.center,
                  items: months.map((month) {
                    final isCurrent = month == months.last;
                    final isSelected = month == selectedMonth;
                    final borderColor = isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary;
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Container(
                        padding: isSelected
                            ? const EdgeInsets.only(bottom: 1)
                            : EdgeInsets.zero,
                        decoration: isSelected
                            ? BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(width: 2, color: borderColor),
                                ),
                              )
                            : null,
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
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return months.map((month) {
                      return Align(
                        alignment: Alignment.center,
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
                    _fetchMoreProducts(sortedProducts);
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
                                PantryIcons(
                                  category:
                                      product.category, // category and key of the svg needs to match
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
