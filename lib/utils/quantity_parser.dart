class QuantityParser {
  /// Extracts the leading integer from a free form string.
  /// 20 liters returns 20.
  /// If no digits are found it returns [defaultValue].
  static int parseLeadingNumber(String text, {int defaultValue = 1}) {
    final match = RegExp(r'^(\d+)').firstMatch(text.trim());
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return defaultValue;
  }

  /// Extracts the unit part all the non digits from a free form string.
  /// 20 liters returns liters.
  static String parseUnit(String text) {
    final match = RegExp(r'^\d+\s*(.*)$').firstMatch(text.trim());
    if (match != null) {
      return match.group(1)?.trim() ?? '';
    }
    return '';
  }

  /// Formats a numeric quantity with the given unit.
  /// If the unit is grams and value >= 1000 it converts to kilograms.
  static String formatQuantity(int value, String unit) {
    if (unit.toLowerCase() == 'gram' || unit.toLowerCase() == 'grams') {
      if (value >= 1000) {
        final kgValue = (value / 1000).toStringAsFixed(1);
        return '$kgValue kg';
      }
    }
    return '$value $unit';
  }
}
