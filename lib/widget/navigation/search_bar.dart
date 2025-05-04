import 'package:flutter/material.dart';

/// Reustable searchbar. Built upon material 3's searchbar.
class CustomSearchBarWidget extends StatefulWidget {
  final List<String> suggestions;
  final ValueChanged<String>? onSuggestionSelected;
  final String? hintText;

  const CustomSearchBarWidget({
    super.key,
    required this.suggestions,
    this.onSuggestionSelected,
    this.hintText,
  });

  @override
  State<CustomSearchBarWidget> createState() => _CustomSearchBarWidgetState();
}

class _CustomSearchBarWidgetState extends State<CustomSearchBarWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _isSearchViewOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Instead of using closeView when canceling, which caused pop bugs, clear text and unfocus.
  void _cancelSearch(SearchController controller) {
    if (_isSearchViewOpen) {
      controller.clear();
      _isSearchViewOpen = false;
    }
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  void _openSearch(SearchController controller) {
    controller.openView();
    _isSearchViewOpen = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          backgroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.primaryContainer,
          ),
          autoFocus: false,
          focusNode: _focusNode,
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // less round than me
            ),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          onTap: () {
            if (!_isSearchViewOpen) {
              _openSearch(controller);
            }
          },
          onChanged: (value) {
            if (!_isSearchViewOpen) {
              _openSearch(controller);
            }
            setState(() {});
          },
          // unfocuses and clears text when pressing outside the search bar.
          onTapOutside: (event) {
            _cancelSearch(controller);
          },
          leading: _focusNode.hasFocus && _isSearchViewOpen
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    _cancelSearch(controller);
                  },
                )
              : const Icon(Icons.search),
          trailing: <Widget>[
            if (controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  setState(() {});
                },
              ),
          ],
          hintText: widget.hintText,
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        final String query = controller.text;
        final List<String> filtered = query.isEmpty
            ? widget.suggestions
            : widget.suggestions
                .where((s) => s.toLowerCase().contains(query.toLowerCase()))
                .toList();
        return List<ListTile>.generate(filtered.length, (int index) {
          final String item = filtered[index];
          return ListTile(
            title: Text(item),
            onTap: () {
              // When a suggestion is tapped, closeview, update flag and unfocus
              controller.closeView(item);
              _isSearchViewOpen = false;
              FocusScope.of(context).unfocus();
              if (widget.onSuggestionSelected != null) {
                widget.onSuggestionSelected!(item);
              }
              setState(() {});
            },
          );
        });
      },
    );
  }
}
