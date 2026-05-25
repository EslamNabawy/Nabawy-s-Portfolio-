import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../data/repositories/supabase_page_section_repository.dart';
import '../domain/entities/page_section.dart';
import '../domain/repositories/page_section_repository.dart';

final pageSectionRepositoryProvider = Provider<PageSectionRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabasePageSectionRepository(client);
});

final pageSectionsProvider = FutureProvider<List<PageSection>>((ref) {
  return ref.watch(pageSectionRepositoryProvider).listSections();
});
