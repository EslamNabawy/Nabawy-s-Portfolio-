import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../settings/application/settings_providers.dart';
import '../../application/deployment_providers.dart';
import '../../domain/entities/deployment_result.dart';

mixin CmsDeploymentState<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool isDeploying = false;
  DeploymentProgress? deploymentProgress;
  DeploymentResult? deploymentResult;
  String? deploymentError;

  void clearDeploymentFeedback() {
    deploymentError = null;
    deploymentResult = null;
    deploymentProgress = null;
  }

  Future<void> runCmsDeployment({required String message}) async {
    setState(() {
      isDeploying = true;
      deploymentProgress = const DeploymentProgress(
        message: 'Dispatching public portfolio rebuild...',
        status: 'pending',
      );
      deploymentError = null;
      deploymentResult = null;
    });

    final session = ref.read(authSessionProvider).value;
    try {
      final result = await ref
          .read(deploymentCoordinatorProvider)
          .deploy(
            message: message,
            triggeredBy: session?.userId,
            onProgress: _setDeploymentProgress,
          );
      ref.invalidate(publishLogsProvider);
      if (mounted) {
        setState(() => deploymentResult = result);
      }
    } on AppException catch (error) {
      ref.invalidate(publishLogsProvider);
      _setDeploymentError(error.message);
    } catch (_) {
      ref.invalidate(publishLogsProvider);
      _setDeploymentError(
        'Deployment failed. Check GitHub CLI authentication and retry.',
      );
    } finally {
      if (mounted) {
        setState(() => isDeploying = false);
      }
    }
  }

  void _setDeploymentProgress(DeploymentProgress progress) {
    if (mounted) {
      setState(() => deploymentProgress = progress);
    }
  }

  void _setDeploymentError(String message) {
    if (mounted) {
      setState(() => deploymentError = message);
    }
  }
}
