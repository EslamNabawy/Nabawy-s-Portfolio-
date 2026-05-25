import '../../../../core/utils/json_readers.dart';

final class SiteConfig {
  const SiteConfig({
    this.id = 'global',
    required this.name,
    required this.headline,
    required this.bio,
    this.resumeUrl,
    this.githubUrl,
    this.linkedinUrl,
    this.email,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String headline;
  final String bio;
  final String? resumeUrl;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SiteConfig.fromJson(JsonMap json) {
    return SiteConfig(
      id: readOptionalString(json, 'id') ?? 'global',
      name: readString(json, 'name'),
      headline: readString(json, 'headline'),
      bio: readString(json, 'bio'),
      resumeUrl: readOptionalString(json, 'resume_url'),
      githubUrl: readOptionalString(json, 'github_url'),
      linkedinUrl: readOptionalString(json, 'linkedin_url'),
      email: readOptionalString(json, 'email'),
      createdAt: readOptionalDateTime(json, 'created_at'),
      updatedAt: readOptionalDateTime(json, 'updated_at'),
    );
  }

  JsonMap toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'headline': headline,
      'bio': bio,
      'resume_url': resumeUrl,
      'github_url': githubUrl,
      'linkedin_url': linkedinUrl,
      'email': email,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  SiteConfig copyWith({
    String? id,
    String? name,
    String? headline,
    String? bio,
    String? resumeUrl,
    String? githubUrl,
    String? linkedinUrl,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SiteConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      headline: headline ?? this.headline,
      bio: bio ?? this.bio,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
