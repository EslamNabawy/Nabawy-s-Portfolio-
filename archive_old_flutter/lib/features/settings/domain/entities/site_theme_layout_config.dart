enum ThemeHeroLayout {
  split('split', 'Split'),
  statement('statement', 'Statement'),
  compact('compact', 'Compact');

  const ThemeHeroLayout(this.value, this.label);
  final String value;
  final String label;
}

enum ThemeSectionOrder {
  recruiterFirst('recruiter_first', 'Recruiter Brief First'),
  projectsFirst('projects_first', 'Projects First');

  const ThemeSectionOrder(this.value, this.label);
  final String value;
  final String label;
}

enum ThemeProjectCardStyle {
  proof('proof', 'Proof Cards'),
  visual('visual', 'Visual Lead'),
  compact('compact', 'Compact List');

  const ThemeProjectCardStyle(this.value, this.label);
  final String value;
  final String label;
}
