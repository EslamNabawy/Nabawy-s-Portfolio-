import 'dart:io';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/developer_tool_result.dart';
import '../../domain/repositories/developer_tools_repository.dart';

DeveloperToolsRepository createPlatformDeveloperToolsRepository() {
  return const LocalDeveloperToolsRepository();
}

final class LocalDeveloperToolsRepository implements DeveloperToolsRepository {
  const LocalDeveloperToolsRepository({
    this.githubRepositoryUrl =
        'https://github.com/EslamNabawy/Nabawy-s-Portfolio-',
    this.githubActionsUrl =
        'https://github.com/EslamNabawy/Nabawy-s-Portfolio-/actions',
    this.liveSiteUrl = 'https://eslamnabawy.github.io/Nabawy-s-Portfolio-/',
  });

  final String githubRepositoryUrl;
  final String githubActionsUrl;
  final String liveSiteUrl;

  @override
  Future<DeveloperToolResult> openAstroInEditor() async {
    final astroPath = _findAstroSourcePath();
    await _startProcess('code', [astroPath]);
    return DeveloperToolResult(message: 'Opened Astro source in VS Code.');
  }

  @override
  Future<DeveloperToolResult> openAstroFolder() async {
    final astroPath = _findAstroSourcePath();
    if (Platform.isWindows) {
      await _startProcess('explorer.exe', [astroPath]);
    } else {
      await _startProcess('open', [astroPath]);
    }
    return DeveloperToolResult(message: 'Opened Astro source folder.');
  }

  @override
  Future<DeveloperToolResult> openGitHubRepository() async {
    await _openUrl(githubRepositoryUrl);
    return DeveloperToolResult(message: 'Opened GitHub repository.');
  }

  @override
  Future<DeveloperToolResult> openGitHubActions() async {
    await _openUrl(githubActionsUrl);
    return DeveloperToolResult(message: 'Opened GitHub Actions.');
  }

  @override
  Future<DeveloperToolResult> openLiveSite() async {
    await _openUrl(liveSiteUrl);
    return DeveloperToolResult(message: 'Opened live portfolio site.');
  }

  String _findAstroSourcePath() {
    for (final candidate in _candidateProjectRoots()) {
      final astroDirectory = Directory(
        _joinPath(candidate.path, 'portfolio_site'),
      );
      final packageFile = File(_joinPath(astroDirectory.path, 'package.json'));
      if (packageFile.existsSync()) {
        return astroDirectory.path;
      }
    }

    throw const DeveloperToolFailure(
      'Could not find portfolio_site source folder. Run this dashboard from the original workspace, or open the GitHub repo.',
    );
  }

  Iterable<Directory> _candidateProjectRoots() sync* {
    yield Directory.current;

    var executableDirectory = File(Platform.resolvedExecutable).parent;
    for (var depth = 0; depth < 10; depth += 1) {
      yield executableDirectory;
      final parent = executableDirectory.parent;
      if (parent.path == executableDirectory.path) {
        break;
      }
      executableDirectory = parent;
    }
  }

  Future<void> _openUrl(String url) async {
    if (Platform.isWindows) {
      await _startProcess('cmd', ['/c', 'start', '', url]);
      return;
    }
    if (Platform.isMacOS) {
      await _startProcess('open', [url]);
      return;
    }
    await _startProcess('xdg-open', [url]);
  }

  Future<void> _startProcess(String executable, List<String> arguments) async {
    try {
      await Process.start(
        executable,
        arguments,
        mode: ProcessStartMode.detached,
        runInShell: Platform.isWindows,
      );
    } on ProcessException catch (error) {
      throw DeveloperToolFailure(
        'Could not start "$executable". Check that it is installed and available on PATH.',
        cause: error,
      );
    }
  }

  String _joinPath(String directory, String child) {
    return '$directory${Platform.pathSeparator}$child';
  }
}
