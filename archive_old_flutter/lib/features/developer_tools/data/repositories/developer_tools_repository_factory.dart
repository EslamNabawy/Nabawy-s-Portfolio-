import '../../domain/repositories/developer_tools_repository.dart';
import 'unsupported_developer_tools_repository.dart'
    if (dart.library.io) 'local_developer_tools_repository_io.dart';

DeveloperToolsRepository createDeveloperToolsRepository() {
  return createPlatformDeveloperToolsRepository();
}
