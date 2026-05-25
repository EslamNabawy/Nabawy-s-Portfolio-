import '../entities/page_section.dart';

abstract interface class PageSectionRepository {
  Future<List<PageSection>> listSections({bool includeDrafts = true});

  Future<PageSection> createSection(PageSection section);

  Future<PageSection> updateSection(PageSection section);

  Future<void> deleteSection(String id);
}
