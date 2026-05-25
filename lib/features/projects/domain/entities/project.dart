import '../../../../core/utils/json_readers.dart';
import 'project_image.dart';

final class Project {
  const Project({
    this.id,
    required this.title,
    required this.slug,
    required this.description,
    this.shortDescription,
    this.role,
    this.impact,
    this.architectureNotes,
    this.caseStudyMarkdown,
    required this.techStack,
    this.images = const <ProjectImage>[],
    this.githubUrl,
    this.liveUrl,
    this.imageUrl,
    this.isPublished = false,
    this.featured = false,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String title;
  final String slug;
  final String description;
  final String? shortDescription;
  final String? role;
  final String? impact;
  final String? architectureNotes;
  final String? caseStudyMarkdown;
  final List<String> techStack;
  final List<ProjectImage> images;
  final String? githubUrl;
  final String? liveUrl;
  final String? imageUrl;
  final bool isPublished;
  final bool featured;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Project.fromJson(JsonMap json) {
    return Project(
      id: readOptionalString(json, 'id'),
      title: readString(json, 'title'),
      slug: readString(json, 'slug'),
      description: readString(json, 'description'),
      shortDescription: readOptionalString(json, 'short_description'),
      role: readOptionalString(json, 'role'),
      impact: readOptionalString(json, 'impact'),
      architectureNotes: readOptionalString(json, 'architecture_notes'),
      caseStudyMarkdown: readOptionalString(json, 'case_study_markdown'),
      techStack: readStringList(json, 'tech_stack'),
      images: _readProjectImages(json),
      githubUrl: readOptionalString(json, 'github_url'),
      liveUrl: readOptionalString(json, 'live_url'),
      imageUrl: readOptionalString(json, 'image_url'),
      isPublished: readBool(json, 'is_published'),
      featured: readBool(json, 'featured'),
      displayOrder: readInt(json, 'display_order'),
      createdAt: readOptionalDateTime(json, 'created_at'),
      updatedAt: readOptionalDateTime(json, 'updated_at'),
    );
  }

  JsonMap toJson() {
    return <String, Object?>{
      if (id != null) 'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'short_description': shortDescription,
      'role': role,
      'impact': impact,
      'architecture_notes': architectureNotes,
      'case_study_markdown': caseStudyMarkdown,
      'tech_stack': techStack,
      'github_url': githubUrl,
      'live_url': liveUrl,
      'image_url': imageUrl,
      'is_published': isPublished,
      'featured': featured,
      'display_order': displayOrder,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Project copyWith({
    String? id,
    String? title,
    String? slug,
    String? description,
    String? shortDescription,
    String? role,
    String? impact,
    String? architectureNotes,
    String? caseStudyMarkdown,
    List<String>? techStack,
    List<ProjectImage>? images,
    String? githubUrl,
    String? liveUrl,
    String? imageUrl,
    bool? isPublished,
    bool? featured,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      role: role ?? this.role,
      impact: impact ?? this.impact,
      architectureNotes: architectureNotes ?? this.architectureNotes,
      caseStudyMarkdown: caseStudyMarkdown ?? this.caseStudyMarkdown,
      techStack: techStack ?? this.techStack,
      images: images ?? this.images,
      githubUrl: githubUrl ?? this.githubUrl,
      liveUrl: liveUrl ?? this.liveUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublished: isPublished ?? this.isPublished,
      featured: featured ?? this.featured,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<ProjectImage> _readProjectImages(JsonMap json) {
    final value = json['project_images'];
    if (value == null) {
      return const <ProjectImage>[];
    }
    if (value is Iterable) {
      final images = value.map((item) {
        if (item is Map<String, Object?>) {
          return ProjectImage.fromJson(item);
        }
        if (item is Map) {
          return ProjectImage.fromJson(JsonMap.from(item));
        }
        throw const FormatException('Project images must be object rows.');
      }).toList();
      images.sort(
        (left, right) => left.displayOrder.compareTo(right.displayOrder),
      );
      return List<ProjectImage>.unmodifiable(images);
    }
    throw const FormatException('Project images must be an array.');
  }
}
