import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/publish_log.dart';
import '../../domain/repositories/publish_log_repository.dart';

final class SupabasePublishLogRepository implements PublishLogRepository {
  const SupabasePublishLogRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<PublishLog>> listLogs({int limit = 50}) async {
    try {
      final rows = await _client
          .from('publish_log')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      return rows.map((row) => PublishLog.fromJson(JsonMap.from(row))).toList();
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure(
        'Invalid publish log payload from Supabase.',
        cause: error,
      );
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while loading publish log.',
        cause: error,
      );
    }
  }

  @override
  Future<PublishLog> createLog(PublishLog log) async {
    try {
      final payload = log.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');
      final row = await _client
          .from('publish_log')
          .insert(payload)
          .select()
          .single();
      return PublishLog.fromJson(JsonMap.from(row));
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure(
        'Invalid publish log payload from Supabase.',
        cause: error,
      );
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while creating publish log.',
        cause: error,
      );
    }
  }

  @override
  Future<PublishLog> updateLog(PublishLog log) async {
    final id = log.id;
    if (id == null || id.trim().isEmpty) {
      throw const ValidationFailure('Publish log id is required for update.');
    }

    try {
      final payload = log.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');
      final row = await _client
          .from('publish_log')
          .update(payload)
          .eq('id', id)
          .select()
          .single();
      return PublishLog.fromJson(JsonMap.from(row));
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure(
        'Invalid publish log payload from Supabase.',
        cause: error,
      );
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while updating publish log.',
        cause: error,
      );
    }
  }
}
