import '../../../core/errors/app_exception.dart';
import '../../settings/domain/entities/publish_log.dart';
import '../../settings/domain/repositories/publish_log_repository.dart';
import '../domain/entities/deployment_result.dart';
import '../domain/repositories/deployment_repository.dart';

final class DeploymentCoordinator {
  const DeploymentCoordinator({
    required this.deploymentRepository,
    required this.publishLogRepository,
  });

  final DeploymentRepository deploymentRepository;
  final PublishLogRepository publishLogRepository;

  Future<DeploymentResult> deploy({
    required String message,
    String? triggeredBy,
    DeploymentProgressCallback? onProgress,
  }) async {
    PublishLog? log;
    try {
      log = await publishLogRepository.createLog(
        PublishLog(
          status: PublishStatus.pending,
          message: message,
          triggeredBy: triggeredBy,
        ),
      );

      final result = await deploymentRepository.triggerDeploy(
        onProgress: onProgress,
      );
      await publishLogRepository.updateLog(
        log.copyWith(
          status: result.isSuccess
              ? PublishStatus.success
              : PublishStatus.failed,
          message: result.message,
          workflowRunUrl: result.runUrl,
        ),
      );
      return result;
    } on AppException catch (error) {
      await _markFailed(log, error.message);
      rethrow;
    } catch (error) {
      const message =
          'Deployment failed. Check GitHub CLI authentication and retry.';
      await _markFailed(log, message);
      throw DeploymentFailure(message, cause: error);
    }
  }

  Future<void> _markFailed(PublishLog? log, String message) async {
    if (log == null) {
      return;
    }
    try {
      await publishLogRepository.updateLog(
        log.copyWith(status: PublishStatus.failed, message: message),
      );
    } catch (_) {
      // Preserve the original deployment error; log repair can be retried later.
    }
  }
}
