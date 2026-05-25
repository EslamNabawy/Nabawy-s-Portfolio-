import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_admin/features/projects/domain/entities/experiment.dart';

void main() {
  test('Experiment parses Supabase row and serializes save payload', () {
    final experiment = Experiment.fromJson(const {
      'id': 'f5b07896-f79b-4bd0-98ce-3e7837bfe859',
      'title': 'Agent Console',
      'slug': 'agent-console',
      'status': 'active',
      'category': 'AI / Agents',
      'summary': 'A command interface for orchestration experiments.',
      'writeup_markdown': '## Notes',
      'media_url': 'https://example.com/agent.png',
      'github_url': 'https://github.com/example/agent-console',
      'live_url': null,
      'display_order': 7,
      'is_published': true,
      'created_at': '2026-05-25T10:00:00Z',
      'updated_at': '2026-05-25T11:00:00Z',
    });

    expect(experiment.status, ExperimentStatus.active);
    expect(experiment.displayOrder, 7);
    expect(experiment.isPublished, isTrue);

    final json = experiment.toJson();
    expect(json['status'], 'active');
    expect(json['writeup_markdown'], '## Notes');
    expect(json['display_order'], 7);
  });
}
