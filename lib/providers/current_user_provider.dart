import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';
import 'package:rxdart/rxdart.dart'; 


/// Emits once on cold start (validates the cached token)  
/// Emits on every onAuthStateChange (login / logout / refresh)
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final supa = Supabase.instance.client;

  Future<AppUser?> _sessionToUser(Session? session) async {
    if (session == null) return null;

    final res = await supa.auth.getUser();
    if (res.user == null) {
      await supa.auth.signOut();
      return null;
    }

    final profile = await supa
        .from('profiles')
        .select()
        .eq('auth_id', res.user!.id)
        .single();

    return AppUser.fromMap(profile, res.user!.email ?? '');
  }

  final initial = _sessionToUser(supa.auth.currentSession).asStream();
  final authStream =
      supa.auth.onAuthStateChange.asyncMap((data) => _sessionToUser(data.session));

  return initial.concatWith([authStream]);
});

final currentUserValueProvider = Provider<AppUser?>((ref) {
  final async = ref.watch(currentUserProvider);
  return async.maybeWhen(data: (u) => u, orElse: () => null);
});