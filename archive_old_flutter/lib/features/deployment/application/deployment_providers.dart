import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/settings_providers.dart';
import 'deployment_coordinator.dart';
import '../data/repositories/deployment_repository_factory.dart';
import '../domain/repositories/deployment_repository.dart';

final deploymentRepositoryProvider = Provider<DeploymentRepository>((ref) {
  return createDeploymentRepository();
});

final deploymentCoordinatorProvider = Provider<DeploymentCoordinator>((ref) {
  return DeploymentCoordinator(
    deploymentRepository: ref.watch(deploymentRepositoryProvider),
    publishLogRepository: ref.watch(publishLogRepositoryProvider),
  );
});
