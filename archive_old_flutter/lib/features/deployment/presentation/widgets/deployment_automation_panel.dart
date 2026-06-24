import 'package:flutter/material.dart';

import '../../domain/entities/deployment_result.dart';
import 'deployment_status_panels.dart';

class DeploymentAutomationPanel extends StatelessWidget {
  const DeploymentAutomationPanel({
    super.key,
    required this.enabled,
    required this.disabledReason,
    required this.deployAfterSave,
    required this.isSaving,
    required this.isDeploying,
    required this.onDeployAfterSaveChanged,
    required this.onSaveAndDeploy,
    this.progress,
    this.result,
    this.error,
  });

  final bool enabled;
  final String disabledReason;
  final bool deployAfterSave;
  final bool isSaving;
  final bool isDeploying;
  final ValueChanged<bool> onDeployAfterSaveChanged;
  final VoidCallback onSaveAndDeploy;
  final DeploymentProgress? progress;
  final DeploymentResult? result;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final busy = isSaving || isDeploying;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Automation', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: enabled && deployAfterSave,
              title: const Text('Deploy after save'),
              subtitle: Text(
                enabled
                    ? 'Run the public rebuild after the next successful save.'
                    : disabledReason,
              ),
              onChanged: enabled && !busy ? onDeployAfterSaveChanged : null,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: enabled && !busy ? onSaveAndDeploy : null,
                icon: isDeploying
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.rocket_launch_outlined),
                label: Text(isDeploying ? 'Deploying...' : 'Save + Deploy'),
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 12),
              DeploymentProgressPanel(progress: progress!),
            ],
            if (result != null) ...[
              const SizedBox(height: 12),
              DeploymentResultPanel(result: result!),
            ],
            if (error != null) ...[
              const SizedBox(height: 12),
              DeploymentErrorPanel(message: error!),
            ],
          ],
        ),
      ),
    );
  }
}
