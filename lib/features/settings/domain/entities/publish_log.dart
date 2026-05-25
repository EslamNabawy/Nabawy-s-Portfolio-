import '../../../../core/utils/json_readers.dart';

enum PublishStatus {
  pending,
  success,
  failed;

  String toJson() => name;

  static PublishStatus fromJson(String value) {
    return switch (value) {
      'pending' => PublishStatus.pending,
      'success' => PublishStatus.success,
      'failed' => PublishStatus.failed,
      _ => throw FormatException('Unknown publish status "$value".'),
    };
  }
}

final class PublishLog {
  const PublishLog({
    this.id,
    required this.status,
    this.message,
    this.workflowRunUrl,
    this.triggeredBy,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final PublishStatus status;
  final String? message;
  final String? workflowRunUrl;
  final String? triggeredBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PublishLog.fromJson(JsonMap json) {
    return PublishLog(
      id: readOptionalString(json, 'id'),
      status: PublishStatus.fromJson(readString(json, 'status')),
      message: readOptionalString(json, 'message'),
      workflowRunUrl: readOptionalString(json, 'workflow_run_url'),
      triggeredBy: readOptionalString(json, 'triggered_by'),
      createdAt: readOptionalDateTime(json, 'created_at'),
      updatedAt: readOptionalDateTime(json, 'updated_at'),
    );
  }

  JsonMap toJson() {
    return <String, Object?>{
      if (id != null) 'id': id,
      'status': status.toJson(),
      'message': message,
      'workflow_run_url': workflowRunUrl,
      'triggered_by': triggeredBy,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  PublishLog copyWith({
    String? id,
    PublishStatus? status,
    String? message,
    String? workflowRunUrl,
    String? triggeredBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PublishLog(
      id: id ?? this.id,
      status: status ?? this.status,
      message: message ?? this.message,
      workflowRunUrl: workflowRunUrl ?? this.workflowRunUrl,
      triggeredBy: triggeredBy ?? this.triggeredBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
