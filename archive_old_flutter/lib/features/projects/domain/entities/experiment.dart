import '../../../../core/utils/json_readers.dart';

enum ExperimentStatus {
  prototype,
  active,
  archived;

  String toJson() => name;

  static ExperimentStatus fromJson(String value) {
    return switch (value) {
      'prototype' => ExperimentStatus.prototype,
      'active' => ExperimentStatus.active,
      'archived' => ExperimentStatus.archived,
      _ => throw FormatException('Unknown experiment status "$value".'),
    };
  }
}

final class Experiment {
  const Experiment({
    this.id,
    required this.title,
    required this.slug,
    this.status = ExperimentStatus.prototype,
    required this.category,
    required this.summary,
    this.writeupMarkdown,
    this.mediaUrl,
    this.githubUrl,
    this.liveUrl,
    this.displayOrder = 0,
    this.isPublished = false,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String title;
  final String slug;
  final ExperimentStatus status;
  final String category;
  final String summary;
  final String? writeupMarkdown;
  final String? mediaUrl;
  final String? githubUrl;
  final String? liveUrl;
  final int displayOrder;
  final bool isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Experiment.fromJson(JsonMap json) {
    return Experiment(
      id: readOptionalString(json, 'id'),
      title: readString(json, 'title'),
      slug: readString(json, 'slug'),
      status: ExperimentStatus.fromJson(readString(json, 'status')),
      category: readString(json, 'category'),
      summary: readString(json, 'summary'),
      writeupMarkdown: readOptionalString(json, 'writeup_markdown'),
      mediaUrl: readOptionalString(json, 'media_url'),
      githubUrl: readOptionalString(json, 'github_url'),
      liveUrl: readOptionalString(json, 'live_url'),
      displayOrder: readInt(json, 'display_order'),
      isPublished: readBool(json, 'is_published'),
      createdAt: readOptionalDateTime(json, 'created_at'),
      updatedAt: readOptionalDateTime(json, 'updated_at'),
    );
  }

  JsonMap toJson() {
    return <String, Object?>{
      if (id != null) 'id': id,
      'title': title,
      'slug': slug,
      'status': status.toJson(),
      'category': category,
      'summary': summary,
      'writeup_markdown': writeupMarkdown,
      'media_url': mediaUrl,
      'github_url': githubUrl,
      'live_url': liveUrl,
      'display_order': displayOrder,
      'is_published': isPublished,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
