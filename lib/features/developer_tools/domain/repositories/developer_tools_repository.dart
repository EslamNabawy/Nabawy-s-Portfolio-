import '../entities/developer_tool_result.dart';

abstract interface class DeveloperToolsRepository {
  Future<DeveloperToolResult> openAstroInEditor();

  Future<DeveloperToolResult> openAstroFolder();

  Future<DeveloperToolResult> openGitHubRepository();

  Future<DeveloperToolResult> openGitHubActions();

  Future<DeveloperToolResult> openLiveSite();
}
