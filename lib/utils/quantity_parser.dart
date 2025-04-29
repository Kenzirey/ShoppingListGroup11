//Generic helpers for the shopping-list UI:
class QuantityParser {
  /* ────────── measurement units we recognise ────────── */
  static const Set<String> _units = {
    // metric
    'g', 'gram', 'grams', 'kg', 'kilogram', 'kilograms',
    'ml', 'l', 'litre', 'litres', 'cl',
    // spoons / cups
    'tsp', 'teaspoon', 'teaspoons',
    'tbsp', 'tablespoon', 'tablespoons',
    'cup', 'cups',
    // kitchen items
    'pinch', 'pinches', 'dash', 'dashes',
    'clove', 'cloves',
    'slice', 'slices',
  };

  static final _reCompact   = RegExp(r'^([\d,.]+)([a-z]+)',  caseSensitive:false);
  static final _reNumUnit   = RegExp(r'^\d+[\d,.]*\s*([a-z]+)', caseSensitive:false);
  static final _reFracUnit  = RegExp(r'^[¼½¾\d\s]+([a-z]+)',   caseSensitive:false);
  static final _reMixedUni  = RegExp(r'^(\d+)\s*([¼½¾⅐⅑⅒⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞])');
  static final _reRange     = RegExp(r'^(\d+)[-–](\d+)');

  // ASCII fractions
  static final _reAsciiMixed = RegExp(r'^(\d+)\s+(\d+)/(\d+)');
  static final _reAsciiFrac  = RegExp(r'^(\d+)/(\d+)');
  static final _reNumber     = RegExp(r'^([\d,.]+)', caseSensitive:false);

  static double parseLeadingNumber(String text, {double defaultValue = 1}) {
    final line = text.trim().toLowerCase();

    // 1) compact “250g”
    final m0 = _reCompact.firstMatch(line);
    if (m0 != null) {
      return double.tryParse(m0.group(1)!.replaceAll(',', '.')) ?? defaultValue;
    }

    // 2) Unicode mixed fraction “1 ½”
    final mUni = _reMixedUni.firstMatch(line);
    if (mUni != null) {
      final whole = double.parse(mUni.group(1)!);
      final frac  = _vulgarToDouble(mUni.group(2)!) ?? 0;
      return whole + frac;
    }

    // 3) ASCII mixed “1 1/2”
    final mMix = _reAsciiMixed.firstMatch(line);
    if (mMix != null) {
      final whole = double.parse(mMix.group(1)!);
      final num   = double.parse(mMix.group(2)!);
      final den   = double.parse(mMix.group(3)!);
      return whole + num / den;
    }

    // 4) ASCII pure “1/2”
    final mFrac = _reAsciiFrac.firstMatch(line);
    if (mFrac != null) {
      final num = double.parse(mFrac.group(1)!);
      final den = double.parse(mFrac.group(2)!);
      return num / den;
    }

    // 5) numeric range “2-3”
    final mRange = _reRange.firstMatch(line);
    if (mRange != null) {
      final low  = double.parse(mRange.group(1)!);
      final high = double.parse(mRange.group(2)!);
      return (low + high) / 2;
    }

    // 6) plain number (kept last so it doesn’t grab the “1” in “1/2”)
    final mNum = _reNumber.firstMatch(line);
    if (mNum != null) {
      return double.tryParse(mNum.group(1)!.replaceAll(',', '.')) ?? defaultValue;
    }

    return defaultValue;
  }

  static String parseUnit(String text) {
    final line = text.trim().toLowerCase();

    String? candidate;

    candidate = _reCompact.firstMatch(line)?.group(2) ??
                _reNumUnit.firstMatch(line)?.group(1) ??
                _reFracUnit.firstMatch(line)?.group(1);

    return (candidate != null && _units.contains(candidate)) ? candidate : '';
  }

  // formatting helper
  static String formatQuantity(num value, String unit) {
    if (['g', 'gram', 'grams'].contains(unit) && value >= 1000) {
      final kg = (value / 1000).toStringAsFixed(1);
      return '$kg kg';
    }
    final vStr = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
    return unit.isEmpty ? vStr : '$vStr $unit';
  }

  // Unicode vulgar-fraction map
  static double? _vulgarToDouble(String c) => const {
        '¼': .25, '½': .5, '¾': .75,
        '⅐': 1 / 7, '⅑': 1 / 9, '⅒': .1,
        '⅓': 1 / 3, '⅔': 2 / 3,
        '⅕': .2, '⅖': .4, '⅗': .6, '⅘': .8,
        '⅙': 1 / 6, '⅚': 5 / 6,
        '⅛': .125, '⅜': .375, '⅝': .625, '⅞': .875,
      }[c];
}
