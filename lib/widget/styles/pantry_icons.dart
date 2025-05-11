// lib/widgets/pantry_icons.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PantryIcons extends StatelessWidget {
  const PantryIcons({
    super.key,
    required this.category,
    this.size = 24.0,
    this.color,
    this.semanticLabel
  });

  final String? category;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final fileName = (category
            ?.toLowerCase()
            .replaceAll(' ', '_')
          ) ?? 'local_grocery_store';

    // fallback to default icon if svg not found (shopping cart) to signify a shopping item (☞ﾟヮﾟ)☞
    try {
      return SvgPicture.asset(
        'assets/icons/$fileName.svg',
        width: size,
        height: size,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        placeholderBuilder: (_) => SizedBox(width: size, height: size),
        semanticsLabel: semanticLabel,
      );
    } catch (_) {
      return Icon(
        Icons.local_grocery_store,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
    }
  }
}
