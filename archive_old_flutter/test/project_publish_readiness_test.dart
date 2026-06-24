import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_admin/features/projects/presentation/screens/project_publish_readiness.dart';

void main() {
  test('assessProjectPublishReadiness returns blockers for unsafe publish', () {
    final issues = assessProjectPublishReadiness(
      title: '',
      slug: 'Bad Slug',
      shortDescription: '',
      description: '',
      techStack: '',
      imageUrl: '',
      galleryImages: '',
      githubUrl: '',
      liveUrl: '',
      role: '',
      impact: '',
      architectureNotes: '',
      caseStudyMarkdown: '',
    );

    expect(hasPublishBlockers(issues), isTrue);
    expect(
      issues.where((issue) => issue.severity == PublishIssueSeverity.blocker),
      hasLength(6),
    );
  });

  test('assessProjectPublishReadiness allows complete publish payload', () {
    final issues = assessProjectPublishReadiness(
      title: 'Rain P2P Messenger',
      slug: 'rain-p2p-messenger',
      shortDescription: 'Decentralized messaging built with WebRTC.',
      description: 'A reliable product-system case study.',
      techStack: 'Flutter, WebRTC, Supabase',
      imageUrl: 'https://example.com/rain.png',
      galleryImages: 'https://example.com/rain-2.png',
      githubUrl: 'https://github.com/example/rain',
      liveUrl: '',
      role: 'Lead engineer',
      impact: 'Shipped encrypted peer messaging prototype.',
      architectureNotes: 'Clean architecture with signaling isolation.',
      caseStudyMarkdown: '## Build Notes',
    );

    expect(hasPublishBlockers(issues), isFalse);
  });
}
