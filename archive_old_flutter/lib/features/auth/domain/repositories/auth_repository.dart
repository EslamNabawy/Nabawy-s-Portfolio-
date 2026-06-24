import '../entities/admin_session.dart';

abstract interface class AuthRepository {
  AdminSession? get currentSession;

  Stream<AdminSession?> get sessionChanges;

  Future<AdminSession> requireAdminAccess(AdminSession session);

  Future<AdminSession> signInWithPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
