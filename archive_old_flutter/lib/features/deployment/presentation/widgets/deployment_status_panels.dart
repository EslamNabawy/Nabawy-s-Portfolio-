import 'package:flutter/material.dart';

import '../../domain/entities/deployment_result.dart';

class DeploymentProgressPanel extends StatelessWidget {
  const DeploymentProgressPanel({super.key, required this.progress});

  final DeploymentProgress progress;

  @override
  Widget build(BuildContext context) {
    return DeploymentStatusPanel(
      color: const Color(0xFFDBEAFE),
      foreground: const Color(0xFF1D4ED8),
      title: 'Deployment status: ${progress.status}',
      body: _body,
    );
  }

  String get _body {
    final run = progress.runUrl == null ? '' : '\nRun: ${progress.runUrl}';
    return '${progress.message}$run';
  }
}

class DeploymentResultPanel extends StatelessWidget {
  const DeploymentResultPanel({super.key, required this.result});

  final DeploymentResult result;

  @override
  Widget build(BuildContext context) {
    final success = result.isSuccess;
    return DeploymentStatusPanel(
      color: success ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
      foreground: success ? const Color(0xFF166534) : const Color(0xFF991B1B),
      title: result.message,
      body: result.runUrl == null
          ? 'Open GitHub Actions to inspect the deployment.'
          : 'Run: ${result.runUrl}',
    );
  }
}

class DeploymentErrorPanel extends StatelessWidget {
  const DeploymentErrorPanel({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DeploymentStatusPanel(
      color: const Color(0xFFFEE2E2),
      foreground: const Color(0xFF991B1B),
      title: 'Deployment failed',
      body: message,
    );
  }
}

class DeploymentStatusPanel extends StatelessWidget {
  const DeploymentStatusPanel({
    super.key,
    required this.color,
    required this.foreground,
    required this.title,
    required this.body,
  });

  final Color color;
  final Color foreground;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(body, style: TextStyle(color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}
