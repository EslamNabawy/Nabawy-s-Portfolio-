import '../../domain/repositories/deployment_repository.dart';
import 'unsupported_deployment_repository.dart'
    if (dart.library.io) 'github_cli_deployment_repository_io.dart';

DeploymentRepository createDeploymentRepository() {
  return createPlatformDeploymentRepository();
}
