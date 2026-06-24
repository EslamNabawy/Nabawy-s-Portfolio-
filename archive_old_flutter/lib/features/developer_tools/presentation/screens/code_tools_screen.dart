import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../application/developer_tools_providers.dart';
import '../../domain/entities/developer_tool_result.dart';

class CodeToolsScreen extends ConsumerStatefulWidget {
  const CodeToolsScreen({super.key});

  @override
  ConsumerState<CodeToolsScreen> createState() => _CodeToolsScreenState();
}

class _CodeToolsScreenState extends ConsumerState<CodeToolsScreen> {
  String? _runningAction;
  DeveloperToolResult? _result;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Code Tools',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Open the web portfolio code, repository, Actions, and live site when you need to change design or fix implementation issues.',
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ToolButton(
                    label: 'Open Astro in VS Code',
                    icon: Icons.code,
                    running: _runningAction == 'vscode',
                    onPressed: () => _run(
                      id: 'vscode',
                      action: ref
                          .read(developerToolsRepositoryProvider)
                          .openAstroInEditor,
                    ),
                  ),
                  _ToolButton(
                    label: 'Open Astro Folder',
                    icon: Icons.folder_open,
                    running: _runningAction == 'folder',
                    onPressed: () => _run(
                      id: 'folder',
                      action: ref
                          .read(developerToolsRepositoryProvider)
                          .openAstroFolder,
                    ),
                  ),
                  _ToolButton(
                    label: 'Open GitHub Repo',
                    icon: Icons.hub_outlined,
                    running: _runningAction == 'repo',
                    onPressed: () => _run(
                      id: 'repo',
                      action: ref
                          .read(developerToolsRepositoryProvider)
                          .openGitHubRepository,
                    ),
                  ),
                  _ToolButton(
                    label: 'Open GitHub Actions',
                    icon: Icons.play_circle_outline,
                    running: _runningAction == 'actions',
                    onPressed: () => _run(
                      id: 'actions',
                      action: ref
                          .read(developerToolsRepositoryProvider)
                          .openGitHubActions,
                    ),
                  ),
                  _ToolButton(
                    label: 'Open Live Site',
                    icon: Icons.public,
                    running: _runningAction == 'site',
                    onPressed: () => _run(
                      id: 'site',
                      action: ref
                          .read(developerToolsRepositoryProvider)
                          .openLiveSite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_result != null) _StatusPanel.success(_result!.message),
              if (_error != null) _StatusPanel.error(_error!),
              const SizedBox(height: 24),
              const _WorkflowCard(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _run({
    required String id,
    required Future<DeveloperToolResult> Function() action,
  }) async {
    setState(() {
      _runningAction = id;
      _error = null;
      _result = null;
    });

    try {
      final result = await action();
      if (!mounted) {
        return;
      }
      setState(() => _result = result);
    } on AppException catch (error) {
      _setError(error.message);
    } catch (_) {
      _setError('Tool action failed. Check local tooling and retry.');
    } finally {
      if (mounted) {
        setState(() => _runningAction = null);
      }
    }
  }

  void _setError(String message) {
    if (mounted) {
      setState(() => _error = message);
    }
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.label,
    required this.icon,
    required this.running,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool running;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 44,
      child: FilledButton.icon(
        onPressed: running ? null : onPressed,
        icon: running
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  const _WorkflowCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code change workflow',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('1. Open Astro in VS Code.'),
            const Text('2. Edit files under portfolio_site/src.'),
            const Text('3. Commit and push code changes.'),
            const Text('4. Use Deploy to rebuild GitHub Pages.'),
          ],
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel._({
    required this.message,
    required this.color,
    required this.foreground,
  });

  factory _StatusPanel.success(String message) {
    return _StatusPanel._(
      message: message,
      color: const Color(0xFFDCFCE7),
      foreground: const Color(0xFF166534),
    );
  }

  factory _StatusPanel.error(String message) {
    return _StatusPanel._(
      message: message,
      color: const Color(0xFFFEE2E2),
      foreground: const Color(0xFF991B1B),
    );
  }

  final String message;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
