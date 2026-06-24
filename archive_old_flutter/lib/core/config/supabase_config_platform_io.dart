import 'dart:convert';
import 'dart:io';

import 'supabase_config_platform.dart';

RuntimeSupabaseConfig readRuntimeSupabaseConfig() {
  final environmentConfig = RuntimeSupabaseConfig(
    url: Platform.environment['SUPABASE_URL'] ?? '',
    anonKey: Platform.environment['SUPABASE_ANON_KEY'] ?? '',
  );
  if (environmentConfig.url.trim().isNotEmpty ||
      environmentConfig.anonKey.trim().isNotEmpty) {
    return environmentConfig;
  }

  return _readConfigFile();
}

RuntimeSupabaseConfig _readConfigFile() {
  for (final path in _candidateConfigPaths()) {
    final file = File(path);
    if (!file.existsSync()) {
      continue;
    }

    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, Object?>) {
        return RuntimeSupabaseConfig(
          url: _readConfigValue(decoded, 'SUPABASE_URL', 'supabaseUrl'),
          anonKey: _readConfigValue(
            decoded,
            'SUPABASE_ANON_KEY',
            'supabaseAnonKey',
          ),
        );
      }
    } on FormatException {
      return const RuntimeSupabaseConfig.empty();
    } on FileSystemException {
      return const RuntimeSupabaseConfig.empty();
    }
  }

  return const RuntimeSupabaseConfig.empty();
}

List<String> _candidateConfigPaths() {
  final executableDirectory = File(Platform.resolvedExecutable).parent.path;
  return [
    _joinPath(executableDirectory, 'supabase_config.json'),
    _joinPath(Directory.current.path, 'supabase_config.json'),
  ];
}

String _joinPath(String directory, String fileName) {
  return '$directory${Platform.pathSeparator}$fileName';
}

String _readConfigValue(
  Map<String, Object?> values,
  String environmentKey,
  String jsonKey,
) {
  final environmentValue = values[environmentKey];
  if (environmentValue is String && environmentValue.trim().isNotEmpty) {
    return environmentValue;
  }

  final jsonValue = values[jsonKey];
  if (jsonValue is String) {
    return jsonValue;
  }

  return '';
}
