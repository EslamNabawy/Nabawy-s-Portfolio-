import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/deployment_result.dart';
import '../../domain/repositories/deployment_repository.dart';

DeploymentRepository createPlatformDeploymentRepository() {
  return const UnsupportedDeploymentRepository();
}

final class UnsupportedDeploymentRepository implements DeploymentRepository {
  const UnsupportedDeploymentRepository();

  @override
  Future<DeploymentResult> triggerDeploy({
    DeploymentProgressCallback? onProgress,
  }) {
    throw const DeploymentFailure(
      'Deployment from this platform is not supported. Use the Windows dashboard or GitHub Actions.',
    );
  }
}
