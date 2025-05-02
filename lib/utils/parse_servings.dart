

int parse_servings(String yields) {
  final match = RegExp(r'\d+').firstMatch(yields);
  return match == null ? 1 : int.parse(match.group(0)!);
}