import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/admin_session.dart';
import '../../domain/repositories/auth_repository.dart';

final class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  AdminSession? get currentSession {
    final session = _client.auth.currentSession;
    return session == null ? null : _mapSession(session);
  }

  @override
  Stream<AdminSession?> get sessionChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final session = event.session;
      return session == null ? null : _mapSession(session);
    });
  }

  @override
  Future<AdminSession> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final session = response.session;
      if (session == null) {
        throw const AuthFailure('Supabase returned no session after login.');
      }
      return requireAdminAccess(_mapSession(session));
    } on AuthException catch (error) {
      throw _mapAuthException(error);
    } on AppException {
      rethrow;
    } catch (error) {
      throw AuthFailure('Unexpected authentication failure.', cause: error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (error) {
      throw AuthFailure(error.message, code: error.statusCode, cause: error);
    } catch (error) {
      throw AuthFailure('Unexpected sign-out failure.', cause: error);
    }
  }

  @override
  Future<AdminSession> requireAdminAccess(AdminSession session) async {
    if (session.isExpired) {
      return session;
    }
    try {
      final row = await _client
          .from('admin_users')
          .select('user_id')
          .eq('user_id', session.userId)
          .maybeSingle();
      if (row == null) {
        await _signOutSilently();
        throw const AuthFailure(
          'This account is not on the portfolio admin allowlist.',
          code: 'not_admin',
        );
      }
      return session;
    } on AppException {
      rethrow;
    } on PostgrestException catch (error) {
      throw AuthFailure(
        'Could not verify admin access.',
        code: error.code,
        cause: error,
      );
    } catch (error) {
      throw AuthFailure('Unexpected admin verification failure.', cause: error);
    }
  }

  Future<void> _signOutSilently() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      // The caller still needs the authorization failure.
    }
  }

  AdminSession _mapSession(Session session) {
    final expiresAt = session.expiresAt;
    return AdminSession(
      userId: session.user.id,
      email: session.user.email,
      expiresAt: expiresAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000, isUtc: true),
    );
  }

  AuthFailure _mapAuthException(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return AuthFailure(
        'Invalid admin email or password.',
        code: error.statusCode,
        cause: error,
      );
    }
    return AuthFailure(error.message, code: error.statusCode, cause: error);
  }
}
