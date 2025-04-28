// Split a free form ingredient line into (qty, unit, name) parts before inserting into the DB.
class IngredientParser {
  static const _vulgar = {
    '¼': '1/4', '½': '1/2', '¾': '3/4',
    '⅐': '1/7', '⅑': '1/9', '⅒': '1/10',
    '⅓': '1/3', '⅔': '2/3',
    '⅕': '1/5', '⅖': '2/5', '⅗': '3/5', '⅘': '4/5',
    '⅙': '1/6', '⅚': '5/6',
    '⅛': '1/8', '⅜': '3/8', '⅝': '5/8', '⅞': '7/8',
  };

  static ({String qty, String unit, String name}) split(String raw) {
    String line = raw.trim();
    line = line.replaceFirst(RegExp(r'^[-•]\s*'), '');

    final tok = line.split(RegExp(r'\s+'));
    if (tok.isEmpty) {
      return (qty: '', unit: '', name: line);
    }

    String qty = '';
    String unit = '';
    int take = 0;

    String vf(String c) => _vulgar[c] ?? c;

    // 1) mixed number  “1 ½”
    if (tok.length > 1 &&
        RegExp(r'^\d+$').hasMatch(tok[0]) &&
        _vulgar.containsKey(tok[1])) {
      qty = '${tok[0]} ${vf(tok[1])}';
      take = 2;
    }
    // 2) standalone vulgar fraction  “½”
    else if (_vulgar.containsKey(tok[0])) {
      qty = vf(tok[0]);
      take = 1;
    }
    // 3) plain number / decimal  “200”  “1,5”
    else if (RegExp(r'^\d+(?:[.,]\d+)?$').hasMatch(tok[0])) {
      qty = tok[0].replaceAll(',', '.');
      take = 1;
    }
    // 4) compact “250g”
    else if (RegExp(r'^(\d+)([a-zA-Z]+)$').hasMatch(tok[0])) {
      final m = RegExp(r'^(\d+)([a-zA-Z]+)$').firstMatch(tok[0])!;
      qty  = m.group(1)!;
      unit = m.group(2)!;
      take = 1;
    }

    if (unit.isEmpty &&
        take < tok.length &&
        RegExp(r'^[a-zA-Z]+\b').hasMatch(tok[take])) {
      unit = tok[take];
      take += 1;
    }

    final name = tok.sublist(take).join(' ').trim();
    return (qty: qty, unit: unit, name: name.isEmpty ? line : name);
  }
}
