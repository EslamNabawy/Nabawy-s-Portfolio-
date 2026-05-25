import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../data/repositories/supabase_publish_log_repository.dart';
import '../data/repositories/supabase_site_config_repository.dart';
import '../domain/entities/publish_log.dart';
import '../domain/entities/site_config.dart';
import '../domain/repositories/publish_log_repository.dart';
import '../domain/repositories/site_config_repository.dart';

final siteConfigRepositoryProvider = Provider<SiteConfigRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSiteConfigRepository(client);
});

final siteConfigProvider = FutureProvider<SiteConfig>((ref) {
  return ref.watch(siteConfigRepositoryProvider).getGlobalConfig();
});

final publishLogRepositoryProvider = Provider<PublishLogRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabasePublishLogRepository(client);
});

final publishLogsProvider = FutureProvider<List<PublishLog>>((ref) {
  return ref.watch(publishLogRepositoryProvider).listLogs();
});
