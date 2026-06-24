import '../entities/experiment.dart';

abstract interface class ExperimentRepository {
  Future<List<Experiment>> listExperiments({bool includeDrafts = true});

  Future<Experiment> createExperiment(Experiment experiment);

  Future<Experiment> updateExperiment(Experiment experiment);

  Future<void> deleteExperiment(String id);
}
