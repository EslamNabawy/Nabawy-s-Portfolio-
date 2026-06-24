import '../../../projects/domain/entities/experiment.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/domain/entities/skill.dart';

final class OverviewContentHealth {
  const OverviewContentHealth({
    required this.publishedProjects,
    required this.draftProjects,
    required this.publishedExperiments,
    required this.draftExperiments,
    required this.publishedSkillGroups,
    required this.warnings,
  });

  final int publishedProjects;
  final int draftProjects;
  final int publishedExperiments;
  final int draftExperiments;
  final int publishedSkillGroups;
  final List<String> warnings;

  factory OverviewContentHealth.from(
    List<Project> projects,
    List<Skill> skills,
    List<Experiment> experiments,
  ) {
    final warnings = <String>[];
    for (final project in projects.where((project) => project.isPublished)) {
      if (_isBlank(project.imageUrl) && project.images.isEmpty) {
        warnings.add('${project.title}: missing primary image.');
      }
      if (_isBlank(project.architectureNotes)) {
        warnings.add('${project.title}: missing architecture notes.');
      }
      if (_isBlank(project.caseStudyMarkdown)) {
        warnings.add('${project.title}: missing case study.');
      }
    }
    for (final experiment in experiments.where((item) => item.isPublished)) {
      if (_isBlank(experiment.summary)) {
        warnings.add('${experiment.title}: missing summary.');
      }
      if (_isBlank(experiment.mediaUrl) &&
          _isBlank(experiment.writeupMarkdown)) {
        warnings.add('${experiment.title}: add media or writeup evidence.');
      }
    }

    return OverviewContentHealth(
      publishedProjects: projects.where((item) => item.isPublished).length,
      draftProjects: projects.where((item) => !item.isPublished).length,
      publishedExperiments: experiments
          .where((item) => item.isPublished)
          .length,
      draftExperiments: experiments.where((item) => !item.isPublished).length,
      publishedSkillGroups: skills.where((item) => item.isPublished).length,
      warnings: List<String>.unmodifiable(warnings),
    );
  }
}

bool _isBlank(String? value) => value == null || value.trim().isEmpty;
