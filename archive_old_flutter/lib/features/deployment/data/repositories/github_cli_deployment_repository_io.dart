import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/deployment_result.dart';
import '../../domain/repositories/deployment_repository.dart';

DeploymentRepository createPlatformDeploymentRepository() {
  return const GitHubCliDeploymentRepository();
}

final class GitHubCliDeploymentRepository implements DeploymentRepository {
  const GitHubCliDeploymentRepository({
    this.owner = 'EslamNabawy',
    this.repo = 'Nabawy-s-Portfolio-',
    this.workflow = 'Deploy Astro Portfolio',
    this.branch = 'main',
    this.pollInterval = const Duration(seconds: 4),
    this.runDiscoveryTimeout = const Duration(seconds: 45),
    this.runCompletionTimeout = const Duration(minutes: 10),
  });

  final String owner;
  final String repo;
  final String workflow;
  final String branch;
  final Duration pollInterval;
  final Duration runDiscoveryTimeout;
  final Duration runCompletionTimeout;

  @override
  Future<DeploymentResult> triggerDeploy({
    DeploymentProgressCallback? onProgress,
  }) async {
    final startedAt = DateTime.now();
    final previousRun = await _latestRunOrNull();
    onProgress?.call(
      const DeploymentProgress(
        message: 'Triggering GitHub Actions workflow...',
        status: 'dispatching',
      ),
    );

    final triggerResult = await _runGh([
      'workflow',
      'run',
      workflow,
      '--ref',
      branch,
      '--repo',
      _repository,
    ]);
    if (triggerResult.exitCode != 0) {
      throw DeploymentFailure(
        _failureMessage(triggerResult),
        code: triggerResult.exitCode.toString(),
      );
    }

    final dispatchedRunUrl = _extractUrl(_combinedOutput(triggerResult));
    onProgress?.call(
      DeploymentProgress(
        message: 'Workflow dispatched. Waiting for run to appear...',
        status: 'queued',
        runUrl: dispatchedRunUrl,
      ),
    );

    final run = await _waitForNewRun(previousRun?.databaseId, onProgress);
    final completedRun = await _waitForCompletion(run, onProgress);
    final success = completedRun.conclusion == 'success';
    return DeploymentResult(
      message: success ? 'Deployment succeeded.' : 'Deployment failed.',
      startedAt: startedAt,
      status: completedRun.status,
      conclusion: completedRun.conclusion,
      runUrl: completedRun.url ?? dispatchedRunUrl,
      runId: completedRun.databaseId,
      completedAt: completedRun.updatedAt,
    );
  }

  String get _repository => '$owner/$repo';

  Future<_GitHubRun?> _latestRunOrNull() async {
    final result = await _runGh([
      'run',
      'list',
      '--workflow',
      workflow,
      '--branch',
      branch,
      '--repo',
      _repository,
      '--limit',
      '1',
      '--json',
      'databaseId,status,conclusion,url,createdAt,updatedAt',
    ]);
    if (result.exitCode != 0) {
      return null;
    }
    final runs = _parseRunList(_combinedOutput(result));
    return runs.isEmpty ? null : runs.first;
  }

  Future<_GitHubRun> _waitForNewRun(
    int? previousRunId,
    DeploymentProgressCallback? onProgress,
  ) async {
    final deadline = DateTime.now().add(runDiscoveryTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final latestRun = await _latestRunOrNull();
      if (latestRun != null && latestRun.databaseId != previousRunId) {
        onProgress?.call(
          DeploymentProgress(
            message: 'Run created. Status: ${latestRun.status}.',
            status: latestRun.status,
            conclusion: latestRun.conclusion,
            runUrl: latestRun.url,
            runId: latestRun.databaseId,
          ),
        );
        return latestRun;
      }
      await Future<void>.delayed(pollInterval);
    }
    throw const DeploymentFailure(
      'Workflow was dispatched, but no new run appeared before timeout.',
    );
  }

  Future<_GitHubRun> _waitForCompletion(
    _GitHubRun run,
    DeploymentProgressCallback? onProgress,
  ) async {
    final deadline = DateTime.now().add(runCompletionTimeout);
    var currentRun = run;
    while (DateTime.now().isBefore(deadline)) {
      currentRun = await _viewRun(currentRun.databaseId);
      onProgress?.call(
        DeploymentProgress(
          message: _messageForRun(currentRun),
          status: currentRun.status,
          conclusion: currentRun.conclusion,
          runUrl: currentRun.url,
          runId: currentRun.databaseId,
        ),
      );
      if (currentRun.status == 'completed') {
        return currentRun;
      }
      await Future<void>.delayed(pollInterval);
    }
    throw DeploymentFailure(
      'Deployment run timed out before completion.',
      code: run.databaseId.toString(),
    );
  }

  Future<_GitHubRun> _viewRun(int databaseId) async {
    final result = await _runGh([
      'run',
      'view',
      databaseId.toString(),
      '--repo',
      _repository,
      '--json',
      'databaseId,status,conclusion,url,createdAt,updatedAt',
    ]);
    if (result.exitCode != 0) {
      throw DeploymentFailure(
        _failureMessage(result),
        code: result.exitCode.toString(),
      );
    }
    return _GitHubRun.fromJson(_decodeObject(_combinedOutput(result)));
  }

  Future<ProcessResult> _runGh(List<String> arguments) async {
    try {
      return await Process.run('gh', arguments, runInShell: Platform.isWindows);
    } on ProcessException catch (error) {
      throw DeploymentFailure(
        'GitHub CLI was not found or could not start. Install GitHub CLI and run "gh auth login".',
        cause: error,
      );
    }
  }

  List<_GitHubRun> _parseRunList(String output) {
    final decoded = jsonDecode(output);
    if (decoded is! List<Object?>) {
      throw const DeploymentFailure(
        'GitHub CLI returned invalid run list JSON.',
      );
    }
    return decoded
        .whereType<Map<String, Object?>>()
        .map(_GitHubRun.fromJson)
        .toList(growable: false);
  }

  Map<String, Object?> _decodeObject(String output) {
    final decoded = jsonDecode(output);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    throw const DeploymentFailure('GitHub CLI returned invalid run JSON.');
  }

  String _messageForRun(_GitHubRun run) {
    if (run.status == 'completed') {
      return run.conclusion == 'success'
          ? 'Deployment completed successfully.'
          : 'Deployment completed with result: ${run.conclusion ?? 'unknown'}.';
    }
    return 'Deployment run status: ${run.status}.';
  }

  String _failureMessage(ProcessResult result) {
    final output = _combinedOutput(result);
    if (output.contains('not logged into')) {
      return 'GitHub CLI is not authenticated. Run "gh auth login" in PowerShell, then retry.';
    }
    if (output.contains('workflow') && output.contains('not found')) {
      return 'GitHub workflow was not found. Confirm the deploy workflow exists on main.';
    }
    if (output.trim().isNotEmpty) {
      return output.trim();
    }
    return 'Failed to trigger GitHub Pages deployment.';
  }

  String _combinedOutput(ProcessResult result) {
    return [
      if (result.stdout case final String stdout when stdout.trim().isNotEmpty)
        stdout.trim(),
      if (result.stderr case final String stderr when stderr.trim().isNotEmpty)
        stderr.trim(),
    ].join('\n');
  }

  String? _extractUrl(String output) {
    final match = RegExp(r'https://\S+').firstMatch(output);
    return match?.group(0);
  }
}

final class _GitHubRun {
  const _GitHubRun({
    required this.databaseId,
    required this.status,
    this.conclusion,
    this.url,
    this.createdAt,
    this.updatedAt,
  });

  final int databaseId;
  final String status;
  final String? conclusion;
  final String? url;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory _GitHubRun.fromJson(Map<String, Object?> json) {
    final databaseId = json['databaseId'];
    final status = json['status'];
    if (databaseId is! int || status is! String) {
      throw const DeploymentFailure('GitHub run payload is missing id/status.');
    }
    return _GitHubRun(
      databaseId: databaseId,
      status: status,
      conclusion: json['conclusion'] as String?,
      url: json['url'] as String?,
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
    );
  }

  static DateTime? _readDateTime(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.parse(value).toUtc();
    }
    return null;
  }
}
