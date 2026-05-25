final class RuntimeSupabaseConfig {
  const RuntimeSupabaseConfig({required this.url, required this.anonKey});

  const RuntimeSupabaseConfig.empty() : this(url: '', anonKey: '');

  final String url;
  final String anonKey;
}

RuntimeSupabaseConfig readRuntimeSupabaseConfig() {
  return const RuntimeSupabaseConfig.empty();
}
