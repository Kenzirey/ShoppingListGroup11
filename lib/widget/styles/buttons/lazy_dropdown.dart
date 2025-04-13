// Updated CustomLazyDropdown with optional Icon

import 'package:flutter/material.dart';

class CustomLazyDropdown extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final IconData? icon;

  const CustomLazyDropdown({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.icon,
  });

  @override
  _CustomLazyDropdownState createState() => _CustomLazyDropdownState();
}

class _CustomLazyDropdownState extends State<CustomLazyDropdown> {
  late String _selectedValue;
  late int _currentItemCount;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final ScrollController _scrollController = ScrollController();
  final double itemHeight = 40;
  final int increment = 15;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _currentItemCount = increment;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < itemHeight) {
      _currentItemCount += increment;
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)!.insert(_overlayEntry!);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  void _scrollToSelected() {
    final selectedIndex = int.tryParse(_selectedValue) ?? 1;
    final initialIndex = int.tryParse(widget.initialValue) ?? 1;
    final offset = (selectedIndex - initialIndex) * itemHeight;

    while (selectedIndex > _currentItemCount + initialIndex - 1) {
      _currentItemCount += increment;
    }

    _overlayEntry?.markNeedsBuild();
    _scrollController.jumpTo(offset);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        final startValue = int.tryParse(widget.initialValue) ?? 1;
        return Positioned(
          left: offset.dx,
          top: offset.dy + size.height,
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: Offset(0, size.height),
            showWhenUnlinked: false,
            child: Material(
              elevation: 4,
              child: SizedBox(
                height: itemHeight * 5,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  itemCount: _currentItemCount,
                  itemBuilder: (context, index) {
                    final value = '${startValue + index}';
                    final bool isSelected = value == _selectedValue;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedValue = value;
                        });
                        widget.onChanged(value);
                        _hideOverlay();
                      },
                      child: Container(
                        height: itemHeight,
                        alignment: Alignment.center,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(widget.icon, size: 16, color: Colors.grey),
                ),
              Text(
                _selectedValue,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
