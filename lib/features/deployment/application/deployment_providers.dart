import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/deployment_repository_factory.dart';
import '../domain/repositories/deployment_repository.dart';

final deploymentRepositoryProvider = Provider<DeploymentRepository>((ref) {
  return createDeploymentRepository();
});
