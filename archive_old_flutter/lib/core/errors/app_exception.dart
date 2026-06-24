sealed class AppException implements Exception {
  const AppException(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() {
    final suffix = code == null ? '' : ' [$code]';
    return '$runtimeType$suffix: $message';
  }
}

final class AuthFailure extends AppException {
  const AuthFailure(super.message, {super.code, super.cause});
}

final class DataFailure extends AppException {
  const DataFailure(super.message, {super.code, super.cause});
}

final class StorageFailure extends AppException {
  const StorageFailure(super.message, {super.code, super.cause});
}

final class ValidationFailure extends AppException {
  const ValidationFailure(super.message, {super.code, super.cause});
}

final class DeploymentFailure extends AppException {
  const DeploymentFailure(super.message, {super.code, super.cause});
}

final class DeveloperToolFailure extends AppException {
  const DeveloperToolFailure(super.message, {super.code, super.cause});
}
