import '../../../../core/utils/json_readers.dart';

final class ProjectImage {
  const ProjectImage({
    this.id,
    this.projectId,
    required this.imageUrl,
    this.altText,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? projectId;
  final String imageUrl;
  final String? altText;
  final int displayOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProjectImage.fromJson(JsonMap json) {
    return ProjectImage(
      id: readOptionalString(json, 'id'),
      projectId: readOptionalString(json, 'project_id'),
      imageUrl: readString(json, 'image_url'),
      altText: readOptionalString(json, 'alt_text'),
      displayOrder: readInt(json, 'display_order'),
      createdAt: readOptionalDateTime(json, 'created_at'),
      updatedAt: readOptionalDateTime(json, 'updated_at'),
    );
  }

  JsonMap toJson() {
    return <String, Object?>{
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      'image_url': imageUrl,
      'alt_text': altText,
      'display_order': displayOrder,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
