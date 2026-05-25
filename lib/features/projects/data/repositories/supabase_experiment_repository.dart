import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/experiment.dart';
import '../../domain/repositories/experiment_repository.dart';

final class SupabaseExperimentRepository implements ExperimentRepository {
  const SupabaseExperimentRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Experiment>> listExperiments({bool includeDrafts = true}) async {
    try {
      var query = _client.from('experiments').select();
      if (!includeDrafts) {
        query = query.eq('is_published', true);
      }
      final rows = await query
          .order('display_order', ascending: true)
          .order('created_at', ascending: false);
      return rows
          .map((row) => Experiment.fromJson(JsonMap.from(row)))
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure(
        'Invalid experiment payload from Supabase.',
        cause: error,
      );
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while loading experiments.',
        cause: error,
      );
    }
  }

  @override
  Future<Experiment> createExperiment(Experiment experiment) async {
    try {
      final row = await _client
          .from('experiments')
          .insert(_payloadForSave(experiment))
          .select()
          .single();
      return Experiment.fromJson(JsonMap.from(row));
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure(
        'Invalid experiment payload from Supabase.',
        cause: error,
      );
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while creating experiment.',
        cause: error,
      );
    }
  }

  @override
  Future<Experiment> updateExperiment(Experiment experiment) async {
    final id = experiment.id;
    if (id == null || id.trim().isEmpty) {
      throw const ValidationFailure('Experiment id is required for update.');
    }
    try {
      final row = await _client
          .from('experiments')
          .update(_payloadForSave(experiment))
          .eq('id', id)
          .select()
          .single();
      return Experiment.fromJson(JsonMap.from(row));
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure(
        'Invalid experiment payload from Supabase.',
        cause: error,
      );
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while updating experiment.',
        cause: error,
      );
    }
  }

  @override
  Future<void> deleteExperiment(String id) async {
    try {
      await _client.from('experiments').delete().eq('id', id);
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while deleting experiment.',
        cause: error,
      );
    }
  }

  JsonMap _payloadForSave(Experiment experiment) {
    return experiment.toJson()
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at');
  }
}
