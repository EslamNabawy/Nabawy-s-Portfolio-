import '../entities/site_config.dart';

abstract interface class SiteConfigRepository {
  Future<SiteConfig> getGlobalConfig();

  Future<SiteConfig> updateGlobalConfig(SiteConfig config);
}
