import 'package:supabase_flutter/supabase_flutter.dart';

final _supa = Supabase.instance.client;

/// Thin helper calls the gemini chat edge function in supabase and
/// returns Geminis raw JSON response (already decoded).
Future<Map<String, dynamic>> geminiRaw({
  required String prompt,
  required String query,
  List<Map<String, dynamic>> history = const [],
}) async {
  final response = await _supa.functions.invoke(
    'gemini-chat',
    body: {'prompt': prompt, 'query': query, 'history': history},
  );

  // Edge functions return 200 on success anything ≥400 is an error.
  if (response.status >= 400 || response.data == null) {
    throw Exception(
      'Edge Function failed (status ${response.status})',
    );
  }

  return response.data as Map<String, dynamic>;
}

