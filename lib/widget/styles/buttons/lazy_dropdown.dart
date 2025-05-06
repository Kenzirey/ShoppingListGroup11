import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Custom dropdown widget for selecting whole numbers with lazy-loading like behavior.
///
/// Only show a few items first, and dynamically expands as scrolled.
class CustomLazyDropdown extends ConsumerStatefulWidget {
  final String initialValue; // text from the database
  final ValueChanged<String> onChanged;
  final IconData? icon;
  final double dropdownWidth;
  final int maxValue;

  const CustomLazyDropdown({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.icon,
    this.dropdownWidth = 48,
    this.maxValue = 999,
  });

  @override
  ConsumerState<CustomLazyDropdown> createState() => _CustomLazyDropdownState();
}

class _CustomLazyDropdownState extends ConsumerState<CustomLazyDropdown> {
  static const double _rowH = 40;
  static const int _chunk =
      15; // rows added top/bottom to start the loading with.
  static const int _vis = 5; // rows onscreen, subject to change

  String _displayLabel = '1';
  int _selected = 1; // just a dummy value to initialize it with.
  int _start =
      1; // first row value, we won't go below it as you can't shop negative items, is that called donating? hm
  int _count = _chunk * 2 + 1; // rows built at the moment

  OverlayEntry? _overlay;
  final LayerLink _link = LayerLink();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // parse numeric part only
    final match = RegExp(r'^(\d+)').firstMatch(widget.initialValue.trim());
    _selected = match != null ? int.parse(match.group(1)!) : 1;
    _displayLabel = _selected.toString();
    _start = (_selected - _chunk).clamp(1, widget.maxValue);
    _count = _chunk * 2 + 1;
    _scroll.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant CustomLazyDropdown old) {
    super.didUpdateWidget(old);
    if (old.initialValue != widget.initialValue) {
      final match = RegExp(r'^(\d+)').firstMatch(widget.initialValue.trim());
      _selected = match != null ? int.parse(match.group(1)!) : 1;
      _displayLabel = _selected.toString();
      _start = (_selected - _chunk).clamp(1, widget.maxValue);
      _count = _chunk * 2 + 1;
      _overlay?.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _overlay?.remove();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < _rowH &&
        _start + _count - 1 < widget.maxValue) {
      setState(() =>
          _count = (_count + _chunk).clamp(0, widget.maxValue - _start + 1));
      _overlay?.markNeedsBuild();
    }
    if (_scroll.position.extentBefore < _rowH && _start > 1) {
      final oldPixels = _scroll.position.pixels;
      final add = _chunk.clamp(0, _start - 1);
      setState(() {
        _start -= add;
        _count += add;
      });
      _overlay?.markNeedsBuild();
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scroll.jumpTo(oldPixels + _rowH * add));
    }
  }

  void _toggle() {
    if (_overlay == null)
      _show();
    else
      _hide();
  }

  void _hide() {
    _overlay?.remove();
    _overlay = null;
  }

  void _show() {
    _overlay = _buildOverlay();
    Overlay.of(context)?.insert(_overlay!);
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerOnSelected());
  }

  void _centerOnSelected() {
    final targetRow = _selected - _start;
    const middle = (_vis ~/ 2);
    final offset = (targetRow - middle) * _rowH;
    _scroll.jumpTo(offset.clamp(0, _scroll.position.maxScrollExtent));
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hide,
            ),
          ),
          Positioned(
            width: widget.dropdownWidth,
            child: CompositedTransformFollower(
              link: _link,
              offset: const Offset(0, _rowH),
              showWhenUnlinked: false,
              child: Material(
                elevation: 4,
                child: SizedBox(
                  height: _rowH * _vis,
                  child: ListView.builder(
                    controller: _scroll,
                    padding: EdgeInsets.zero,
                    itemExtent: _rowH,
                    itemCount: _count,
                    itemBuilder: (_, i) {
                      final value = _start + i;
                      final isSel = value == _selected;
                      final cs = Theme.of(context).colorScheme;
                      return InkWell(
                        onTap: () => _onItemTap(value),
                        child: Center(
                          child: Text(
                            value.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isSel ? FontWeight.bold : FontWeight.normal,
                              color: isSel ? cs.primary : cs.tertiary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTap(int value) {
    setState(() {
      _selected = value;
      _displayLabel = value.toString();
    });
    widget.onChanged(_displayLabel);
    _hide();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: Container(
          alignment: Alignment.center,
          width: widget.dropdownWidth,
          height: _rowH,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16, color: Colors.grey),
                const SizedBox(width: 1),
              ],
              const SizedBox(width: 2),
              Text(
                _displayLabel,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 1),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
