import '../entities/skill.dart';

abstract interface class SkillRepository {
  Future<List<Skill>> listSkills({bool includeDrafts = true});

  Future<Skill> createSkill(Skill skill);

  Future<Skill> updateSkill(Skill skill);

  Future<void> deleteSkill(String id);
}
