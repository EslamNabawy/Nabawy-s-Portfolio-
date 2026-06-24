import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/skill.dart';
import '../../domain/repositories/skill_repository.dart';

final class SupabaseSkillRepository implements SkillRepository {
  const SupabaseSkillRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Skill>> listSkills({bool includeDrafts = true}) async {
    try {
      var query = _client.from('skills').select();
      if (!includeDrafts) {
        query = query.eq('is_published', true);
      }
      final rows = await query.order('display_order', ascending: true);
      return rows.map((row) => Skill.fromJson(JsonMap.from(row))).toList();
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure('Invalid skill payload from Supabase.', cause: error);
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while loading skills.',
        cause: error,
      );
    }
  }

  @override
  Future<Skill> createSkill(Skill skill) async {
    try {
      final payload = skill.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');
      final row = await _client
          .from('skills')
          .insert(payload)
          .select()
          .single();
      return Skill.fromJson(JsonMap.from(row));
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure('Invalid skill payload from Supabase.', cause: error);
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while creating skill.',
        cause: error,
      );
    }
  }

  @override
  Future<Skill> updateSkill(Skill skill) async {
    final id = skill.id;
    if (id == null || id.trim().isEmpty) {
      throw const ValidationFailure('Skill id is required for update.');
    }

    try {
      final payload = skill.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');
      final row = await _client
          .from('skills')
          .update(payload)
          .eq('id', id)
          .select()
          .single();
      return Skill.fromJson(JsonMap.from(row));
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure('Invalid skill payload from Supabase.', cause: error);
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while updating skill.',
        cause: error,
      );
    }
  }

  @override
  Future<void> deleteSkill(String id) async {
    try {
      await _client.from('skills').delete().eq('id', id);
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while deleting skill.',
        cause: error,
      );
    }
  }
}
