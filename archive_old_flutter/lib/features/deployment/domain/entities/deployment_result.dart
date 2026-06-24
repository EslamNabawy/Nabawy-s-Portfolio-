final class DeploymentResult {
  const DeploymentResult({
    required this.message,
    required this.startedAt,
    required this.status,
    this.conclusion,
    this.runUrl,
    this.runId,
    this.completedAt,
  });

  final String message;
  final DateTime startedAt;
  final String status;
  final String? conclusion;
  final String? runUrl;
  final int? runId;
  final DateTime? completedAt;

  bool get isSuccess => conclusion == 'success';
}

final class DeploymentProgress {
  const DeploymentProgress({
    required this.message,
    required this.status,
    this.conclusion,
    this.runUrl,
    this.runId,
  });

  final String message;
  final String status;
  final String? conclusion;
  final String? runUrl;
  final int? runId;
}
