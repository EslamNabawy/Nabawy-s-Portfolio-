import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_admin/core/errors/app_exception.dart';
import 'package:portfolio_admin/features/deployment/application/deployment_coordinator.dart';
import 'package:portfolio_admin/features/deployment/domain/entities/deployment_result.dart';
import 'package:portfolio_admin/features/deployment/domain/repositories/deployment_repository.dart';
import 'package:portfolio_admin/features/settings/domain/entities/publish_log.dart';
import 'package:portfolio_admin/features/settings/domain/repositories/publish_log_repository.dart';

void main() {
  test('deploy writes pending and success publish log rows', () async {
    final logs = _FakePublishLogRepository();
    final deployment = _FakeDeploymentRepository.success();
    final coordinator = DeploymentCoordinator(
      deploymentRepository: deployment,
      publishLogRepository: logs,
    );

    final result = await coordinator.deploy(
      message: 'Deploy after save.',
      triggeredBy: 'admin-user',
    );

    expect(result.isSuccess, isTrue);
    expect(logs.created.single.message, 'Deploy after save.');
    expect(logs.created.single.status, PublishStatus.pending);
    expect(logs.created.single.triggeredBy, 'admin-user');
    expect(logs.updated.single.status, PublishStatus.success);
    expect(logs.updated.single.workflowRunUrl, 'https://github.com/run/1');
  });

  test('deploy marks publish log failed when workflow trigger fails', () async {
    final logs = _FakePublishLogRepository();
    final deployment = _FakeDeploymentRepository.failure();
    final coordinator = DeploymentCoordinator(
      deploymentRepository: deployment,
      publishLogRepository: logs,
    );

    await expectLater(
      coordinator.deploy(message: 'Deploy after save.'),
      throwsA(isA<DeploymentFailure>()),
    );

    expect(logs.created.single.status, PublishStatus.pending);
    expect(logs.updated.single.status, PublishStatus.failed);
    expect(logs.updated.single.message, 'GitHub CLI failed.');
  });
}

final class _FakeDeploymentRepository implements DeploymentRepository {
  const _FakeDeploymentRepository._({required this.shouldFail});

  factory _FakeDeploymentRepository.success() {
    return const _FakeDeploymentRepository._(shouldFail: false);
  }

  factory _FakeDeploymentRepository.failure() {
    return const _FakeDeploymentRepository._(shouldFail: true);
  }

  final bool shouldFail;

  @override
  Future<DeploymentResult> triggerDeploy({
    DeploymentProgressCallback? onProgress,
  }) async {
    if (shouldFail) {
      throw const DeploymentFailure('GitHub CLI failed.');
    }
    return DeploymentResult(
      message: 'Deployment succeeded.',
      startedAt: DateTime.utc(2026),
      status: 'completed',
      conclusion: 'success',
      runUrl: 'https://github.com/run/1',
      runId: 1,
      completedAt: DateTime.utc(2026, 1, 1, 0, 1),
    );
  }
}

final class _FakePublishLogRepository implements PublishLogRepository {
  final created = <PublishLog>[];
  final updated = <PublishLog>[];

  @override
  Future<List<PublishLog>> listLogs({int limit = 50}) async {
    return [...updated, ...created].take(limit).toList(growable: false);
  }

  @override
  Future<PublishLog> createLog(PublishLog log) async {
    final saved = PublishLog(
      id: 'log-${created.length + 1}',
      status: log.status,
      message: log.message,
      workflowRunUrl: log.workflowRunUrl,
      triggeredBy: log.triggeredBy,
    );
    created.add(saved);
    return saved;
  }

  @override
  Future<PublishLog> updateLog(PublishLog log) async {
    updated.add(log);
    return log;
  }
}
