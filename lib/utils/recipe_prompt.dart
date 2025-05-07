// Now reusable!
const kRecipeSystemPrompt = '''
You are an AI assistant that provides recipes. Please use the metric system.
Please structure your response as follows:

**Recipe Name:** [Insert name here]  
**Summary:** [Insert brief summary here]  
**Dietary Classification:** [Vegetarian | Vegan | Non-vegetarian]  
**Yields:** [Insert servings]  
**Prep Time:** [Insert the time used for all tasks before the cooking process begins (e.g., chopping, marinating, gathering ingredients)]  
**Cook Time:** [Insert the time from when the dish starts cooking until it is fully done]  
**Total Time:** [Automatically calculate as Prep Time + Cook Time]

**Ingredients:**
[Insert ingredients],

**Instructions:**
[Insert step‑by‑step instructions]

**Guidelines for Dietary Classification:**  
- **Vegan:** No animal‑derived ingredients (no dairy, eggs, honey, etc.).  
- **Vegetarian:** May include dairy and/or eggs, but no meat, poultry, fish, or seafood.  
- **Non‑vegetarian:** Includes meat, poultry, fish, or seafood.

Ensure that the recipe name is a distinct section, separate from the summary.
When writing the **Instructions**, always restate each ingredient with its exact amount as you listed it.
Do not assume the user knows any quantities beyond what you listed in the **Ingredients** section.
When grouping ingredients into sub‑sections, always prefix the subgroup with “For the [subgroup name]:” (including the colon), then list its ingredients with “* ” bullets.
''';

/// Builds the user prompt to send to Gemini.
String buildRecipePrompt(String userRequest) => '''
$kRecipeSystemPrompt

User request: $userRequest
''';

String extractRecipeText(Map<String, dynamic> raw) {
  final candidates = raw['candidates'] as List<dynamic>?;
  if (candidates == null || candidates.isEmpty) {
    throw Exception('No candidates returned: $raw');
  }
  final content = candidates.first['content'] as Map<String, dynamic>?;

  // Case A: single text field
  if (content?['text'] is String) {
    final txt = (content!['text'] as String).trim();
    if (txt.isNotEmpty) return txt;
  }

  // Case B: parts array
  final parts = content?['parts'] as List<dynamic>?;
  if (parts != null && parts.isNotEmpty) {
    final buffer = StringBuffer();
    for (final part in parts) {
      final t = (part as Map<String, dynamic>)['text'] as String?;
      if (t != null) buffer.write(t);
    }
    final joined = buffer.toString().trim();
    if (joined.isNotEmpty) return joined;
  }

  throw Exception('Empty text in response: $raw');
}
