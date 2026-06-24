import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/json_readers.dart';
import '../../domain/entities/page_section.dart';
import '../../domain/repositories/page_section_repository.dart';

final class SupabasePageSectionRepository implements PageSectionRepository {
  const SupabasePageSectionRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<PageSection>> listSections({bool includeDrafts = true}) async {
    try {
      var query = _client.from('page_sections').select();
      if (!includeDrafts) {
        query = query.eq('is_published', true);
      }
      final rows = await query
          .order('placement', ascending: true)
          .order('display_order', ascending: true)
          .order('created_at', ascending: false);
      return rows
          .map((row) => PageSection.fromJson(JsonMap.from(row)))
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure(
        'Invalid page section payload from Supabase.',
        cause: error,
      );
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while loading page sections.',
        cause: error,
      );
    }
  }

  @override
  Future<PageSection> createSection(PageSection section) async {
    try {
      final row = await _client
          .from('page_sections')
          .insert(_payloadForSave(section))
          .select()
          .single();
      return PageSection.fromJson(JsonMap.from(row));
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure(
        'Invalid page section payload from Supabase.',
        cause: error,
      );
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while creating page section.',
        cause: error,
      );
    }
  }

  @override
  Future<PageSection> updateSection(PageSection section) async {
    final id = section.id;
    if (id == null || id.trim().isEmpty) {
      throw const ValidationFailure('Page section id is required for update.');
    }
    try {
      final row = await _client
          .from('page_sections')
          .update(_payloadForSave(section))
          .eq('id', id)
          .select()
          .single();
      return PageSection.fromJson(JsonMap.from(row));
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } on FormatException catch (error) {
      throw DataFailure(
        'Invalid page section payload from Supabase.',
        cause: error,
      );
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while updating page section.',
        cause: error,
      );
    }
  }

  @override
  Future<void> deleteSection(String id) async {
    try {
      await _client.from('page_sections').delete().eq('id', id);
    } on PostgrestException catch (error) {
      throw DataFailure(error.message, code: error.code, cause: error);
    } catch (error) {
      throw DataFailure(
        'Unexpected failure while deleting page section.',
        cause: error,
      );
    }
  }

  JsonMap _payloadForSave(PageSection section) {
    return section.toJson()
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at');
  }
}
