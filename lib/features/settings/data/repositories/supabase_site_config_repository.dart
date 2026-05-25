import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/site_config.dart';
import '../../domain/repositories/site_config_repository.dart';

final class SupabaseSiteConfigRepository implements SiteConfigRepository {
  const SupabaseSiteConfigRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<SiteConfig> getGlobalConfig() async {
    try {
      final row = await _client
          .from('site_config')
          .select()
          .eq('id', 'global')
          .single();
      return SiteConfig.fromJson(JsonMap.from(row));
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure(
        'Invalid site config payload from Supabase.',
        cause: error,
      );
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while loading site config.',
        cause: error,
      );
    }
  }

  @override
  Future<SiteConfig> updateGlobalConfig(SiteConfig config) async {
    try {
      final payload = config.copyWith(id: 'global').toJson()
        ..remove('created_at')
        ..remove('updated_at');
      final row = await _client
          .from('site_config')
          .upsert(payload, onConflict: 'id')
          .select()
          .single();
      return SiteConfig.fromJson(JsonMap.from(row));
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure(
        'Invalid site config payload from Supabase.',
        cause: error,
      );
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while saving site config.',
        cause: error,
      );
    }
  }
}
