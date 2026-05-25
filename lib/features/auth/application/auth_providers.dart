import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../data/repositories/supabase_auth_repository.dart';
import '../domain/entities/admin_session.dart';
import '../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(client);
});

final authSessionProvider = StreamProvider<AdminSession?>((ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  final currentSession = repository.currentSession;
  yield currentSession == null
      ? null
      : await repository.requireAdminAccess(currentSession);

  await for (final session in repository.sessionChanges) {
    yield session == null ? null : await repository.requireAdminAccess(session);
  }
});
