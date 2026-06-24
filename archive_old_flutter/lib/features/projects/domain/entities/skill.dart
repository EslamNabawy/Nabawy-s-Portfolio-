import '../../../../core/utils/json_readers.dart';

final class Skill {
  const Skill({
    this.id,
    required this.category,
    required this.items,
    this.displayOrder = 0,
    this.isPublished = true,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String category;
  final List<String> items;
  final int displayOrder;
  final bool isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Skill.fromJson(JsonMap json) {
    return Skill(
      id: readOptionalString(json, 'id'),
      category: readString(json, 'category'),
      items: readStringList(json, 'items'),
      displayOrder: readInt(json, 'display_order'),
      isPublished: readBool(json, 'is_published', defaultValue: true),
      createdAt: readOptionalDateTime(json, 'created_at'),
      updatedAt: readOptionalDateTime(json, 'updated_at'),
    );
  }

  JsonMap toJson() {
    return <String, Object?>{
      if (id != null) 'id': id,
      'category': category,
      'items': items,
      'display_order': displayOrder,
      'is_published': isPublished,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Skill copyWith({
    String? id,
    String? category,
    List<String>? items,
    int? displayOrder,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Skill(
      id: id ?? this.id,
      category: category ?? this.category,
      items: items ?? this.items,
      displayOrder: displayOrder ?? this.displayOrder,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
