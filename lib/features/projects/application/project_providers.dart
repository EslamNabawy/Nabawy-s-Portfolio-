import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../data/repositories/supabase_skill_repository.dart';
import '../data/repositories/supabase_project_repository.dart';
import '../domain/entities/project.dart';
import '../domain/entities/skill.dart';
import '../domain/repositories/project_repository.dart';
import '../domain/repositories/skill_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseProjectRepository(client);
});

final projectsProvider = FutureProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).listProjects();
});

final skillRepositoryProvider = Provider<SkillRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSkillRepository(client);
});

final skillsProvider = FutureProvider<List<Skill>>((ref) {
  return ref.watch(skillRepositoryProvider).listSkills();
});
