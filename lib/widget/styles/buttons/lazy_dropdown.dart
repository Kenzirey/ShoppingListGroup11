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
  final int maxValue; // don't think you need to pick up more than 100 items at a store, who knows.

  const CustomLazyDropdown({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.icon,
    this.dropdownWidth = 48,
    this.maxValue = 100,
  });

  @override
  ConsumerState<CustomLazyDropdown> createState() => _CustomLazyDropdownState();
}

class _CustomLazyDropdownState extends ConsumerState<CustomLazyDropdown> {

  static const double _rowH = 40;
  static const int _chunk = 15; // rows added top/bottom to start the loading with.
  static const int _vis = 5; // rows onscreen, subject to change

  int _toInt(String s) {
    final m = RegExp(r'^(\d+)').firstMatch(s.trim());
    return (m != null) ? int.parse(m.group(1)!) : 1;
  }

  int _selected = 1; // just a dummy value to initialize it with.
  int _start = 1; // first row value, we won't go below it as you can't shop negative items, is that called donating? hm
  int _count = _chunk * 2 + 1; // rows built at the moment

  OverlayEntry? _overlay;
  final LayerLink _link = LayerLink();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();

    _selected = _toInt(widget.initialValue);
    _start = (_selected - _chunk).clamp(1, widget.maxValue);
    _count = _chunk * 2 + 1; // 15 below + selected + 15 above

    _scroll.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant CustomLazyDropdown old) {
    super.didUpdateWidget(old);
    if (old.initialValue != widget.initialValue) {
      setState(() {
        _selected = _toInt(widget.initialValue);
        _start = (_selected - _chunk).clamp(1, widget.maxValue);
      });
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _overlay?.remove();
    super.dispose();
  }

  // expand "lazily"
  void _onScroll() {
    // bottom 🔽
    if (_scroll.position.extentAfter < _rowH &&
        _start + _count - 1 < widget.maxValue) {
      setState(() =>
          _count = (_count + _chunk).clamp(0, widget.maxValue - _start + 1));
      _overlay?.markNeedsBuild();
    }
    // top 🔝
    if (_scroll.position.extentBefore < _rowH && _start > 1) {
      final oldPixels = _scroll.position.pixels;
      setState(() {
        final add = _chunk.clamp(0, _start - 1);
        _start -= add;
        _count += add;
      });
      _overlay?.markNeedsBuild();
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scroll.jumpTo(oldPixels + _rowH * _chunk));
    }
  }

  // open sesame
  void _toggle() => _overlay == null ? _show() : _hide();
  void _hide() {
    _overlay?.remove();
    _overlay = null;
  }

  void _show() {
    _overlay = _buildOverlay();
    Overlay.of(context).insert(_overlay!);
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
          // so that we can actually tap out to close it
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hide,
            ),
          ),
          // dropdown 😎
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
                        onTap: () {
                          setState(() => _selected = value);
                          widget.onChanged(value.toString());
                          _hide();
                        },
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

  // Action area below
  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        child: Container(
          width: widget.dropdownWidth,
          height: _rowH,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // "number" just a bit to the left so that it looks a bit better with the chevron to the right.
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Text(
                  _selected.toString(),
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
              // dropdown chevron on the right (putting it slightly more to the right so it doesn't kiss the contents 👄)
              const Positioned(
                right: -3,
                child: Icon(Icons.arrow_drop_down, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
