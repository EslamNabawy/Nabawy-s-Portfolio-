import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_admin/features/projects/presentation/screens/project_form_mapper.dart';

void main() {
  test('projectImagesFromForm keeps primary first and deduplicates urls', () {
    final images = projectImagesFromForm(
      title: 'Rain',
      imageUrl: 'https://example.com/primary.png',
      galleryImages: '''
https://example.com/primary.png
https://example.com/second.png
https://example.com/third.png
''',
    );

    expect(images, hasLength(3));
    expect(images[0].imageUrl, 'https://example.com/primary.png');
    expect(images[0].displayOrder, 0);
    expect(images[1].imageUrl, 'https://example.com/second.png');
    expect(images[2].altText, 'Rain image 3');
  });
}
