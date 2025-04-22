import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Converts Supabases auth stream into a Listenable for GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<Session?> stream) {
    notifyListeners();
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Session?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final authRefreshListenable = GoRouterRefreshStream(
  Supabase.instance.client.auth.onAuthStateChange
      .map((data) => data.session),
);
