import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/developer_tool_result.dart';
import '../../domain/repositories/developer_tools_repository.dart';

DeveloperToolsRepository createPlatformDeveloperToolsRepository() {
  return const UnsupportedDeveloperToolsRepository();
}

final class UnsupportedDeveloperToolsRepository
    implements DeveloperToolsRepository {
  const UnsupportedDeveloperToolsRepository();

  @override
  Future<DeveloperToolResult> openAstroFolder() => _unsupported();

  @override
  Future<DeveloperToolResult> openAstroInEditor() => _unsupported();

  @override
  Future<DeveloperToolResult> openGitHubActions() => _unsupported();

  @override
  Future<DeveloperToolResult> openGitHubRepository() => _unsupported();

  @override
  Future<DeveloperToolResult> openLiveSite() => _unsupported();

  Future<DeveloperToolResult> _unsupported() {
    throw const DeveloperToolFailure(
      'Code tools are only available in the Windows desktop dashboard.',
    );
  }
}
