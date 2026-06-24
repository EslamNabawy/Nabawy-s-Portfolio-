import 'supabase_config_platform.dart'
    if (dart.library.io) 'supabase_config_platform_io.dart'
    as platform;

final class SupabaseConfig {
  const SupabaseConfig({required this.url, required this.anonKey});

  final String url;
  final String anonKey;

  bool get isValid {
    final normalizedUrl = url.trim();
    final normalizedAnonKey = anonKey.trim();
    return normalizedUrl.isNotEmpty &&
        normalizedAnonKey.isNotEmpty &&
        normalizedAnonKey != 'PASTE_YOUR_SUPABASE_ANON_KEY_HERE';
  }
}

SupabaseConfig readSupabaseConfig() {
  const definedUrl = String.fromEnvironment('SUPABASE_URL');
  const definedAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  final runtimeConfig = platform.readRuntimeSupabaseConfig();

  return SupabaseConfig(
    url: _preferDefinedValue(definedUrl, runtimeConfig.url),
    anonKey: _preferDefinedValue(definedAnonKey, runtimeConfig.anonKey),
  );
}

String _preferDefinedValue(String definedValue, String runtimeValue) {
  final trimmedDefinedValue = definedValue.trim();
  if (trimmedDefinedValue.isNotEmpty) {
    return trimmedDefinedValue;
  }
  return runtimeValue.trim();
}
