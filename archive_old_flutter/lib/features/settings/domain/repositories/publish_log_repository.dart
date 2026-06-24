import '../entities/publish_log.dart';

abstract interface class PublishLogRepository {
  Future<List<PublishLog>> listLogs({int limit = 50});

  Future<PublishLog> createLog(PublishLog log);

  Future<PublishLog> updateLog(PublishLog log);
}
