import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/developer_tools_repository_factory.dart';
import '../domain/repositories/developer_tools_repository.dart';

final developerToolsRepositoryProvider = Provider<DeveloperToolsRepository>((
  ref,
) {
  return createDeveloperToolsRepository();
});
