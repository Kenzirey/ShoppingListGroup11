

// Parse the number of servings from a string. Remove "approximately" from view, if it has made it to the database.
int parseServings(String yields) {
  final cleaned = yields
    .replaceAll(
      RegExp(r"\bapprox(?:imately)?\.?\b", caseSensitive: false),
      '',
    )
    .trim();
  final match = RegExp(r'\d+').firstMatch(cleaned);
  return match == null ? 1 : int.parse(match.group(0)!);
}
