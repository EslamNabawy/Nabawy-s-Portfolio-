import '../entities/deployment_result.dart';

typedef DeploymentProgressCallback = void Function(DeploymentProgress progress);

abstract interface class DeploymentRepository {
  Future<DeploymentResult> triggerDeploy({
    DeploymentProgressCallback? onProgress,
  });
}
