import '../../../../core/utils/json_readers.dart';
import 'site_theme_config.dart';

enum PublicDesignVariant {
  commandCenter('command_center', 'Command Center'),
  cleanDossier('clean_dossier', 'Clean Dossier'),
  terminalOps('terminal_ops', 'Terminal Ops'),
  signalStudio('signal_studio', 'Signal Studio'),
  systemForge('system_forge', 'System Forge');

  const PublicDesignVariant(this.value, this.label);

  final String value;
  final String label;

  static PublicDesignVariant fromJson(String value) {
    return switch (value) {
      'command_center' => PublicDesignVariant.commandCenter,
      'clean_dossier' => PublicDesignVariant.cleanDossier,
      'terminal_ops' => PublicDesignVariant.terminalOps,
      'signal_studio' => PublicDesignVariant.signalStudio,
      'system_forge' => PublicDesignVariant.systemForge,
      _ => throw FormatException('Unknown public design variant "$value".'),
    };
  }
}

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
    this.designVariant = PublicDesignVariant.commandCenter,
    this.themeConfig = const SiteThemeConfig(),
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
  final PublicDesignVariant designVariant;
  final SiteThemeConfig themeConfig;
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
      designVariant: PublicDesignVariant.fromJson(
        readOptionalString(json, 'design_variant') ?? 'command_center',
      ),
      themeConfig: SiteThemeConfig.fromJson(readJsonObject(json, 'theme_json')),
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
      'design_variant': designVariant.value,
      'theme_json': themeConfig.toJson(),
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
    PublicDesignVariant? designVariant,
    SiteThemeConfig? themeConfig,
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
      designVariant: designVariant ?? this.designVariant,
      themeConfig: themeConfig ?? this.themeConfig,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
