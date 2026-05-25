import '../../../../core/utils/json_readers.dart';

final class AdminSession {
  const AdminSession({
    required this.userId,
    required this.email,
    required this.expiresAt,
  });

  final String userId;
  final String? email;
  final DateTime? expiresAt;

  bool get isExpired {
    final expiry = expiresAt;
    if (expiry == null) {
      return false;
    }
    return DateTime.now().toUtc().isAfter(expiry);
  }

  factory AdminSession.fromJson(JsonMap json) {
    return AdminSession(
      userId: readString(json, 'user_id'),
      email: readOptionalString(json, 'email'),
      expiresAt: readOptionalDateTime(json, 'expires_at'),
    );
  }

  JsonMap toJson() {
    return <String, Object?>{
      'user_id': userId,
      'email': email,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}
